import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/features/courses/domain/course.dart';
import 'package:learning_dashboard/features/courses/domain/lesson.dart';

class CourseDto {
  const CourseDto._();

  static List<Course> listFromJson(Object? json) {
    if (json is! List) throw const ServerException('Expected a list');
    return json.map(fromJson).toList();
  }

  static Course fromJson(Object? json) {
    if (json case {
      'id': final int id,
      'title': final String title,
      'instructor': final String instructor,
      'lessons': final List<dynamic> lessons,
    }) {
      return Course(
        id: id,
        title: title,
        instructor: instructor,
        lessons: lessons.map(_lessonFromJson).toList(),
      );
    }
    throw const ServerException('Malformed course');
  }

  static Lesson _lessonFromJson(Object? json) {
    if (json case {'id': final int id, 'title': final String title}) {
      return Lesson(
        id: id,
        title: title,
        isCompleted: json['completed'] == true,
      );
    }
    throw const ServerException('Malformed lesson');
  }
}
