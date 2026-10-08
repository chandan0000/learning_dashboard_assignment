import 'package:learning_dashboard/features/courses/domain/course.dart';

class CoursesResult {
  const CoursesResult({required this.courses, required this.isFromCache});

  final List<Course> courses;
  final bool isFromCache;
}

abstract interface class CourseRepository {
  Future<CoursesResult> fetchCourses();

  Future<List<Course>> getCachedCourses();

  Future<Course> getCourse(int courseId);

  Future<Course> completeLesson({required int courseId, required int lessonId});
}
