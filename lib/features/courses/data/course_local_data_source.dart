import 'package:learning_dashboard/core/database/app_database.dart';
import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/features/courses/domain/course.dart';
import 'package:learning_dashboard/features/courses/domain/lesson.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class CourseLocalDataSource {
  Future<List<Course>> getCourses();

  Future<Course?> getCourse(int courseId);

  Future<void> replaceCourses(List<Course> courses);

  Future<void> markLessonCompleted({
    required int courseId,
    required int lessonId,
  });
}

class SqfliteCourseLocalDataSource implements CourseLocalDataSource {
  SqfliteCourseLocalDataSource(this._db);

  final Database _db;

  static const String _courses = AppDatabase.coursesTable;
  static const String _lessons = AppDatabase.lessonsTable;

  @override
  Future<List<Course>> getCourses() => _guard(() async {
    final courseRows = await _db.query(_courses, orderBy: 'position');
    final lessonRows = await _db.query(_lessons, orderBy: 'position');

    final lessonsByCourse = <int, List<Lesson>>{};
    for (final row in lessonRows) {
      lessonsByCourse
          .putIfAbsent(row['course_id']! as int, () => [])
          .add(_lessonFromRow(row));
    }

    return [
      for (final row in courseRows)
        _courseFromRow(row, lessonsByCourse[row['id']] ?? const []),
    ];
  });

  @override
  Future<Course?> getCourse(int courseId) => _guard(() async {
    final courseRows = await _db.query(
      _courses,
      where: 'id = ?',
      whereArgs: [courseId],
      limit: 1,
    );
    if (courseRows.isEmpty) return null;

    final lessonRows = await _db.query(
      _lessons,
      where: 'course_id = ?',
      whereArgs: [courseId],
      orderBy: 'position',
    );
    return _courseFromRow(
      courseRows.first,
      lessonRows.map(_lessonFromRow).toList(),
    );
  });

  @override
  Future<void> replaceCourses(List<Course> courses) => _guard(() {
    return _db.transaction((txn) async {
      await txn.delete(_courses);

      final batch = txn.batch();
      for (final (courseIndex, course) in courses.indexed) {
        batch.insert(_courses, {
          'id': course.id,
          'title': course.title,
          'instructor': course.instructor,
          'position': courseIndex,
        });
        for (final (lessonIndex, lesson) in course.lessons.indexed) {
          batch.insert(_lessons, {
            'id': lesson.id,
            'course_id': course.id,
            'title': lesson.title,
            'is_completed': lesson.isCompleted ? 1 : 0,
            'position': lessonIndex,
          });
        }
      }
      await batch.commit(noResult: true);
    });
  });

  @override
  Future<void> markLessonCompleted({
    required int courseId,
    required int lessonId,
  }) => _guard(() async {
    final updated = await _db.update(
      _lessons,
      {'is_completed': 1},
      where: 'course_id = ? AND id = ?',
      whereArgs: [courseId, lessonId],
    );
    if (updated == 0) throw const NotFoundException('Lesson not found');
  });

  Course _courseFromRow(Map<String, Object?> row, List<Lesson> lessons) {
    return Course(
      id: row['id']! as int,
      title: row['title']! as String,
      instructor: row['instructor']! as String,
      lessons: lessons,
    );
  }

  Lesson _lessonFromRow(Map<String, Object?> row) {
    return Lesson(
      id: row['id']! as int,
      title: row['title']! as String,
      isCompleted: row['is_completed'] == 1,
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (e) {
      throw CacheException(e.toString());
    }
  }
}
