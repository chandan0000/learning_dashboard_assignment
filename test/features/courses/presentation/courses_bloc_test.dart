import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/features/courses/domain/course_repository.dart';
import 'package:learning_dashboard/features/courses/presentation/dashboard/bloc/courses_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

class _MockCourseRepository extends Mock implements CourseRepository {}

void main() {
  late _MockCourseRepository repository;

  setUp(() => repository = _MockCourseRepository());

  CoursesBloc buildBloc() => CoursesBloc(courseRepository: repository);

  group('CoursesFetchRequested', () {
    blocTest<CoursesBloc, CoursesState>(
      'emits [loading, success] with courses from the network',
      setUp: () => when(repository.fetchCourses).thenAnswer(
        (_) async => const CoursesResult(
          courses: [pythonCourse, genAiCourse],
          isFromCache: false,
        ),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const CoursesFetchRequested()),
      expect: () => const [
        CoursesState(status: CoursesStatus.loading),
        CoursesState(
          status: CoursesStatus.success,
          courses: [pythonCourse, genAiCourse],
        ),
      ],
    );

    blocTest<CoursesBloc, CoursesState>(
      'flags the state as offline when data came from the cache',
      setUp: () => when(repository.fetchCourses).thenAnswer(
        (_) async =>
            const CoursesResult(courses: [pythonCourse], isFromCache: true),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const CoursesFetchRequested()),
      skip: 1,
      expect: () => const [
        CoursesState(
          status: CoursesStatus.success,
          courses: [pythonCourse],
          isOffline: true,
        ),
      ],
    );

    blocTest<CoursesBloc, CoursesState>(
      'emits success with an empty list (empty state)',
      setUp: () => when(repository.fetchCourses).thenAnswer(
        (_) async => const CoursesResult(courses: [], isFromCache: false),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const CoursesFetchRequested()),
      verify: (bloc) => expect(bloc.state.isEmpty, isTrue),
    );

    blocTest<CoursesBloc, CoursesState>(
      'emits failure when there is no network and no cache',
      setUp: () =>
          when(repository.fetchCourses).thenThrow(const NetworkException()),
      build: buildBloc,
      act: (bloc) => bloc.add(const CoursesFetchRequested()),
      expect: () => const [
        CoursesState(status: CoursesStatus.loading),
        CoursesState(
          status: CoursesStatus.failure,
          failure: NetworkException(),
        ),
      ],
    );

    blocTest<CoursesBloc, CoursesState>(
      'keeps the list visible while refreshing',
      setUp: () => when(repository.fetchCourses).thenAnswer(
        (_) async => const CoursesResult(
          courses: [pythonCourse, genAiCourse],
          isFromCache: false,
        ),
      ),
      build: buildBloc,
      seed: () => const CoursesState(
        status: CoursesStatus.success,
        courses: [pythonCourse],
      ),
      act: (bloc) => bloc.add(const CoursesFetchRequested()),
      expect: () => const [
        CoursesState(
          status: CoursesStatus.success,
          courses: [pythonCourse],
          isRefreshing: true,
        ),
        CoursesState(
          status: CoursesStatus.success,
          courses: [pythonCourse, genAiCourse],
        ),
      ],
    );
  });

  blocTest<CoursesBloc, CoursesState>(
    'CoursesCacheReloadRequested picks up progress made on the details screen',
    setUp: () => when(
      repository.getCachedCourses,
    ).thenAnswer((_) async => [pythonCourse.completeLesson(3)]),
    build: buildBloc,
    seed: () => const CoursesState(
      status: CoursesStatus.success,
      courses: [pythonCourse],
    ),
    act: (bloc) => bloc.add(const CoursesCacheReloadRequested()),
    verify: (bloc) => expect(bloc.state.courses.single.progressPercent, 75),
  );
}
