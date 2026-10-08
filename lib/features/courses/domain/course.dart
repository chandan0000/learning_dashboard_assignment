import 'package:equatable/equatable.dart';
import 'package:learning_dashboard/features/courses/domain/lesson.dart';

class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.lessons,
  });

  final int id;
  final String title;
  final String instructor;
  final List<Lesson> lessons;

  int get lessonCount => lessons.length;

  int get completedLessonCount => lessons.where((l) => l.isCompleted).length;

  int get progressPercent {
    if (lessons.isEmpty) return 0;
    return (completedLessonCount * 100 / lessonCount).round();
  }

  bool get isCompleted =>
      lessons.isNotEmpty && completedLessonCount == lessonCount;

  Course completeLesson(int lessonId) {
    return copyWith(
      lessons: [
        for (final lesson in lessons)
          if (lesson.id == lessonId) lesson.markCompleted() else lesson,
      ],
    );
  }

  Course copyWith({
    String? title,
    String? instructor,
    List<Lesson>? lessons,
  }) {
    return Course(
      id: id,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      lessons: lessons ?? this.lessons,
    );
  }

  @override
  List<Object?> get props => [id, title, instructor, lessons];
}
