import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_dashboard/core/error/error_message.dart';
import 'package:learning_dashboard/core/widgets/message_view.dart';
import 'package:learning_dashboard/features/courses/domain/course.dart';
import 'package:learning_dashboard/features/courses/domain/course_repository.dart';
import 'package:learning_dashboard/features/courses/domain/lesson.dart';
import 'package:learning_dashboard/features/courses/presentation/dashboard/widgets/course_card.dart';
import 'package:learning_dashboard/features/courses/presentation/detail/bloc/course_detail_bloc.dart';
import 'package:learning_dashboard/l10n/l10n.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({required this.courseId, super.key});

  final int courseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseDetailBloc(
        courseId: courseId,
        courseRepository: context.read<CourseRepository>(),
      )..add(const CourseDetailRequested()),
      child: const CourseDetailView(),
    );
  }
}

class CourseDetailView extends StatelessWidget {
  const CourseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<CourseDetailBloc, CourseDetailState>(
      listenWhen: (previous, current) =>
          current.completionFailure != null &&
          previous.completionFailure != current.completionFailure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.completionFailure!.localizedMessage(l10n)),
            ),
          );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(state.course?.title ?? '')),
          body: switch (state.status) {
            CourseDetailStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            CourseDetailStatus.failure => MessageView(
              icon: Icons.error_outline,
              title: state.loadFailure!.localizedMessage(l10n),
              actionLabel: l10n.retry,
              onAction: () => context.read<CourseDetailBloc>().add(
                const CourseDetailRequested(),
              ),
            ),
            CourseDetailStatus.success => _CourseDetailBody(
              course: state.course!,
            ),
          },
        );
      },
    );
  }
}

class _CourseDetailBody extends StatelessWidget {
  const _CourseDetailBody({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(course.title, style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(l10n.byInstructor(course.instructor)),
              const SizedBox(height: 20),
              CourseProgressBar(percent: course.progressPercent),
              const SizedBox(height: 8),
              Text(
                course.isCompleted
                    ? l10n.courseFinished
                    : l10n.lessonsProgress(
                        course.completedLessonCount,
                        course.lessonCount,
                      ),
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              Text(l10n.lessonsHeader, style: textTheme.titleMedium),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (final (index, lesson) in course.lessons.indexed)
          _LessonTile(
            key: ValueKey(lesson.id),
            number: index + 1,
            lesson: lesson,
          ),
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.number, required this.lesson, super.key});

  final int number;
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        lesson.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: lesson.isCompleted ? Colors.green : colors.outline,
      ),
      title: Text('$number. ${lesson.title}'),
      subtitle: Text(
        lesson.isCompleted ? l10n.lessonCompleted : l10n.lessonPending,
      ),
      trailing: lesson.isCompleted
          ? null
          : TextButton(
              onPressed: () => context.read<CourseDetailBloc>().add(
                LessonCompletionRequested(lesson.id),
              ),
              child: Text(l10n.markComplete),
            ),
    );
  }
}
