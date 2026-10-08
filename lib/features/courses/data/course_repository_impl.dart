import 'dart:async';
import 'dart:developer';

import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/features/courses/data/course_api.dart';
import 'package:learning_dashboard/features/courses/data/course_local_data_source.dart';
import 'package:learning_dashboard/features/courses/domain/course.dart';
import 'package:learning_dashboard/features/courses/domain/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  CourseRepositoryImpl({
    required this._api,
    required CourseLocalDataSource localDataSource,
  }) : _local = localDataSource;

  final CourseApi _api;
  final CourseLocalDataSource _local;

  @override
  Future<CoursesResult> fetchCourses() async {
    try {
      final remoteCourses = await _api.fetchCourses();
      final merged = await _keepLocalCompletions(remoteCourses);
      await _local.replaceCourses(merged);
      return CoursesResult(courses: merged, isFromCache: false);
    } on AppException catch (error) {
      final cached = await _local.getCourses();
      if (cached.isEmpty) rethrow;

      log('Serving ${cached.length} cached courses ($error)', name: 'Courses');
      return CoursesResult(courses: cached, isFromCache: true);
    }
  }

  @override
  Future<List<Course>> getCachedCourses() => _local.getCourses();

  @override
  Future<Course> getCourse(int courseId) async {
    final course = await _local.getCourse(courseId);
    if (course == null) throw const NotFoundException('Course not found');
    return course;
  }

  @override
  Future<Course> completeLesson({
    required int courseId,
    required int lessonId,
  }) async {
    await _local.markLessonCompleted(courseId: courseId, lessonId: lessonId);

    unawaited(_pushCompletion(courseId: courseId, lessonId: lessonId));

    return getCourse(courseId);
  }

  Future<void> _pushCompletion({
    required int courseId,
    required int lessonId,
  }) async {
    try {
      await _api.markLessonCompleted(courseId: courseId, lessonId: lessonId);
    } on AppException catch (error) {
      log('Lesson $lessonId sync deferred ($error)', name: 'Courses');
    }
  }

  Future<List<Course>> _keepLocalCompletions(List<Course> remote) async {
    final cached = await _local.getCourses();
    final completedLocally = {
      for (final course in cached)
        for (final lesson in course.lessons)
          if (lesson.isCompleted) (course.id, lesson.id),
    };
    if (completedLocally.isEmpty) return remote;

    return [
      for (final course in remote)
        course.copyWith(
          lessons: [
            for (final lesson in course.lessons)
              if (completedLocally.contains((course.id, lesson.id)))
                lesson.markCompleted()
              else
                lesson,
          ],
        ),
    ];
  }
}
