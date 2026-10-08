part of 'courses_bloc.dart';

enum CoursesStatus { initial, loading, success, failure }

final class CoursesState extends Equatable {
  const CoursesState({
    this.status = CoursesStatus.initial,
    this.courses = const [],
    this.isOffline = false,
    this.isRefreshing = false,
    this.failure,
  });

  final CoursesStatus status;
  final List<Course> courses;

  final bool isOffline;

  final bool isRefreshing;

  final AppException? failure;

  bool get isEmpty => status == CoursesStatus.success && courses.isEmpty;

  CoursesState copyWith({
    CoursesStatus? status,
    List<Course>? courses,
    bool? isOffline,
    bool? isRefreshing,
    AppException? failure,
  }) {
    return CoursesState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      isOffline: isOffline ?? this.isOffline,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    courses,
    isOffline,
    isRefreshing,
    failure,
  ];
}
