part of 'courses_bloc.dart';

sealed class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object?> get props => [];
}

final class CoursesFetchRequested extends CoursesEvent {
  const CoursesFetchRequested();
}

final class CoursesCacheReloadRequested extends CoursesEvent {
  const CoursesCacheReloadRequested();
}
