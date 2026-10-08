import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/features/courses/domain/course_repository.dart';
import 'package:learning_dashboard/features/courses/presentation/detail/bloc/course_detail_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

class _MockCourseRepository extends Mock implements CourseRepository {}

void main() {
  late _MockCourseRepository repository;

  setUp(() => repository = _MockCourseRepository());

  CourseDetailBloc buildBloc() =>
      CourseDetailBloc(courseId: pythonCourse.id, courseRepository: repository);

  const loaded = CourseDetailState(
    status: CourseDetailStatus.success,
    course: pythonCourse,
  );

  blocTest<CourseDetailBloc, CourseDetailState>(
    'loads the course from the repository',
    setUp: () => when(
      () => repository.getCourse(1),
    ).thenAnswer((_) async => pythonCourse),
    build: buildBloc,
    act: (bloc) => bloc.add(const CourseDetailRequested()),
    expect: () => const [CourseDetailState(), loaded],
  );

  blocTest<CourseDetailBloc, CourseDetailState>(
    'marking a lesson complete updates its status and the course progress',
    setUp: () => when(
      () => repository.completeLesson(courseId: 1, lessonId: 3),
    ).thenAnswer((_) async => pythonCourse.completeLesson(3)),
    build: buildBloc,
    seed: () => loaded,
    act: (bloc) => bloc.add(const LessonCompletionRequested(3)),
    verify: (bloc) {
      final course = bloc.state.course!;
      expect(course.lessons[2].isCompleted, isTrue);
      expect(course.progressPercent, 75);
    },
  );

  blocTest<CourseDetailBloc, CourseDetailState>(
    'does not call the repository for an already completed lesson',
    build: buildBloc,
    seed: () => loaded,
    act: (bloc) => bloc.add(const LessonCompletionRequested(1)),
    expect: () => const <CourseDetailState>[],
    verify: (_) => verifyNever(
      () => repository.completeLesson(
        courseId: any(named: 'courseId'),
        lessonId: any(named: 'lessonId'),
      ),
    ),
  );

  blocTest<CourseDetailBloc, CourseDetailState>(
    'keeps the course on screen and reports the error if saving fails',
    setUp: () => when(
      () => repository.completeLesson(courseId: 1, lessonId: 3),
    ).thenThrow(const CacheException()),
    build: buildBloc,
    seed: () => loaded,
    act: (bloc) => bloc.add(const LessonCompletionRequested(3)),
    expect: () => const [
      CourseDetailState(
        status: CourseDetailStatus.success,
        course: pythonCourse,
        completionFailure: CacheException(),
      ),
    ],
  );
}
