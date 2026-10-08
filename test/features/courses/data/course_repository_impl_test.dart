import 'package:flutter_test/flutter_test.dart';
import 'package:learning_dashboard/core/database/app_database.dart';
import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/features/courses/data/course_api.dart';
import 'package:learning_dashboard/features/courses/data/course_local_data_source.dart';
import 'package:learning_dashboard/features/courses/data/course_repository_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/helpers.dart';

class _MockCourseApi extends Mock implements CourseApi {}

void main() {
  late _MockCourseApi api;
  late Database db;
  late CourseRepositoryImpl repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    api = _MockCourseApi();
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repository = CourseRepositoryImpl(
      api: api,
      localDataSource: SqfliteCourseLocalDataSource(db),
    );
    when(
      () => api.markLessonCompleted(
        courseId: any(named: 'courseId'),
        lessonId: any(named: 'lessonId'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() => db.close());

  void goOnline() => when(
    api.fetchCourses,
  ).thenAnswer((_) async => [pythonCourse, genAiCourse]);

  void goOffline() =>
      when(api.fetchCourses).thenThrow(const NetworkException());

  group('fetchCourses', () {
    test('returns fresh data and caches it when online', () async {
      goOnline();

      final result = await repository.fetchCourses();

      expect(result.isFromCache, isFalse);
      expect(result.courses, [pythonCourse, genAiCourse]);
      expect(await repository.getCachedCourses(), [pythonCourse, genAiCourse]);
    });

    test('falls back to the cache when the network fails', () async {
      goOnline();
      await repository.fetchCourses();

      goOffline();
      final result = await repository.fetchCourses();

      expect(result.isFromCache, isTrue);
      expect(result.courses, [pythonCourse, genAiCourse]);
    });

    test('throws when offline and nothing was ever cached', () async {
      goOffline();

      await expectLater(
        repository.fetchCourses(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('completeLesson', () {
    setUp(() async {
      goOnline();
      await repository.fetchCourses();
    });

    test('updates lesson status and course progress in the cache', () async {
      final updated = await repository.completeLesson(courseId: 1, lessonId: 3);

      expect(updated.lessons[2].isCompleted, isTrue);
      expect(updated.progressPercent, 75);
      expect((await repository.getCourse(1)).progressPercent, 75);
    });

    test(
      'works offline and is not undone by the next server refresh',
      () async {
        when(
          () => api.markLessonCompleted(
            courseId: any(named: 'courseId'),
            lessonId: any(named: 'lessonId'),
          ),
        ).thenThrow(const NetworkException());
        await repository.completeLesson(courseId: 1, lessonId: 3);

        final result = await repository.fetchCourses();

        final python = result.courses.firstWhere((c) => c.id == 1);
        expect(python.lessons[2].isCompleted, isTrue);
        expect(python.progressPercent, 75);
      },
    );

    test('throws NotFoundException for an unknown lesson', () async {
      await expectLater(
        repository.completeLesson(courseId: 1, lessonId: 999),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
