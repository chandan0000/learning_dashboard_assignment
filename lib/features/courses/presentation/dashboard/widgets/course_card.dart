import 'package:flutter/material.dart';
import 'package:learning_dashboard/features/courses/domain/course.dart';
import 'package:learning_dashboard/l10n/l10n.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({required this.course, required this.onContinue, super.key});

  final Course course;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onContinue,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(course.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                l10n.byInstructor(course.instructor),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              CourseProgressBar(percent: course.progressPercent),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.lessonsCount(course.lessonCount),
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  FilledButton.tonal(
                    onPressed: onContinue,
                    child: Text(l10n.continueButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseProgressBar extends StatelessWidget {
  const CourseProgressBar({required this.percent, super.key});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: percent / 100, minHeight: 8),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          context.l10n.progressPercent(percent),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}
