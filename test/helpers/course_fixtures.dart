import 'package:learning_dashboard/features/courses/domain/course.dart';
import 'package:learning_dashboard/features/courses/domain/lesson.dart';

const pythonCourse = Course(
  id: 1,
  title: 'Python Programming',
  instructor: 'John Smith',
  lessons: [
    Lesson(id: 1, title: 'Introduction', isCompleted: true),
    Lesson(id: 2, title: 'Variables & Data Types', isCompleted: true),
    Lesson(id: 3, title: 'Functions'),
    Lesson(id: 4, title: 'OOP'),
  ],
);

const genAiCourse = Course(
  id: 2,
  title: 'Generative AI',
  instructor: 'Sarah Williams',
  lessons: [
    Lesson(id: 1, title: 'What is Generative AI'),
    Lesson(id: 2, title: 'Transformers'),
    Lesson(id: 3, title: 'Prompt Engineering'),
  ],
);
