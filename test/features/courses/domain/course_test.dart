import 'package:flutter_test/flutter_test.dart';
import 'package:learning_dashboard/features/courses/domain/course.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('Course progress', () {
    test('is the rounded share of completed lessons', () {
      expect(pythonCourse.progressPercent, 50);
      expect(genAiCourse.progressPercent, 0);

      final oneThird = genAiCourse.completeLesson(1);
      expect(oneThird.progressPercent, 33);
      expect(oneThird.completeLesson(2).progressPercent, 67);
    });

    test('is 0 for a course without lessons (no division by zero)', () {
      const empty = Course(id: 9, title: 't', instructor: 'i', lessons: []);

      expect(empty.progressPercent, 0);
      expect(empty.isCompleted, isFalse);
    });

    test('completeLesson updates status, count and progress together', () {
      final updated = pythonCourse.completeLesson(3);

      expect(updated.lessons[2].isCompleted, isTrue);
      expect(updated.completedLessonCount, 3);
      expect(updated.progressPercent, 75);
      expect(pythonCourse.progressPercent, 50);
    });

    test('completing every lesson marks the course as completed', () {
      final done = pythonCourse.completeLesson(3).completeLesson(4);

      expect(done.progressPercent, 100);
      expect(done.isCompleted, isTrue);
    });

    test('ignores unknown or already completed lessons', () {
      expect(pythonCourse.completeLesson(999), pythonCourse);
      expect(pythonCourse.completeLesson(1), pythonCourse);
    });
  });
}
