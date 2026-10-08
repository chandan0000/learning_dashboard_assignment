import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/features/courses/domain/course.dart';
import 'package:learning_dashboard/features/courses/domain/course_repository.dart';

part 'course_detail_event.dart';
part 'course_detail_state.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  CourseDetailBloc({
    required this.courseId,
    required CourseRepository courseRepository,
  }) : _repository = courseRepository,
       super(const CourseDetailState()) {
    on<CourseDetailRequested>(_onRequested);
    on<LessonCompletionRequested>(
      _onLessonCompleted,
      transformer: sequential(),
    );
  }

  final int courseId;
  final CourseRepository _repository;

  Future<void> _onRequested(
    CourseDetailRequested event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(state.copyWith(status: CourseDetailStatus.loading));
    try {
      final course = await _repository.getCourse(courseId);
      emit(state.copyWith(status: CourseDetailStatus.success, course: course));
    } on AppException catch (error) {
      emit(
        state.copyWith(status: CourseDetailStatus.failure, loadFailure: error),
      );
    }
  }

  Future<void> _onLessonCompleted(
    LessonCompletionRequested event,
    Emitter<CourseDetailState> emit,
  ) async {
    final course = state.course;
    if (course == null) return;

    final alreadyDone = course.lessons.any(
      (l) => l.id == event.lessonId && l.isCompleted,
    );
    if (alreadyDone) return;

    try {
      final updated = await _repository.completeLesson(
        courseId: courseId,
        lessonId: event.lessonId,
      );
      emit(state.copyWith(course: updated));
    } on AppException catch (error) {
      emit(state.copyWith(completionFailure: error));
    }
  }
}
