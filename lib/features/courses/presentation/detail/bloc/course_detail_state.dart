part of 'course_detail_bloc.dart';

enum CourseDetailStatus { loading, success, failure }

final class CourseDetailState extends Equatable {
  const CourseDetailState({
    this.status = CourseDetailStatus.loading,
    this.course,
    this.loadFailure,
    this.completionFailure,
  });

  final CourseDetailStatus status;

  final Course? course;

  final AppException? loadFailure;

  final AppException? completionFailure;

  CourseDetailState copyWith({
    CourseDetailStatus? status,
    Course? course,
    AppException? loadFailure,
    AppException? completionFailure,
  }) {
    return CourseDetailState(
      status: status ?? this.status,
      course: course ?? this.course,
      loadFailure: loadFailure,
      completionFailure: completionFailure,
    );
  }

  @override
  List<Object?> get props => [status, course, loadFailure, completionFailure];
}
