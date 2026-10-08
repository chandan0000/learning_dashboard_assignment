import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/features/courses/domain/course.dart';
import 'package:learning_dashboard/features/courses/domain/course_repository.dart';

part 'courses_event.dart';
part 'courses_state.dart';

class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  CoursesBloc({required CourseRepository courseRepository})
    : _repository = courseRepository,
      super(const CoursesState()) {
    on<CoursesFetchRequested>(_onFetchRequested, transformer: droppable());
    on<CoursesCacheReloadRequested>(_onCacheReloadRequested);
  }

  final CourseRepository _repository;

  Future<void> _onFetchRequested(
    CoursesFetchRequested event,
    Emitter<CoursesState> emit,
  ) async {
    final hasData = state.courses.isNotEmpty;

    emit(
      hasData
          ? state.copyWith(isRefreshing: true, failure: state.failure)
          : state.copyWith(status: CoursesStatus.loading),
    );

    try {
      final result = await _repository.fetchCourses();
      emit(
        CoursesState(
          status: CoursesStatus.success,
          courses: result.courses,
          isOffline: result.isFromCache,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: CoursesStatus.failure,
          isRefreshing: false,
          failure: error,
        ),
      );
    }
  }

  Future<void> _onCacheReloadRequested(
    CoursesCacheReloadRequested event,
    Emitter<CoursesState> emit,
  ) async {
    if (state.status != CoursesStatus.success) return;
    try {
      final courses = await _repository.getCachedCourses();
      emit(state.copyWith(courses: courses));
    } on AppException catch (error) {
      emit(state.copyWith(failure: error));
    }
  }
}
