import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_dashboard/app/router/app_router.dart';
import 'package:learning_dashboard/core/error/error_message.dart';
import 'package:learning_dashboard/core/widgets/message_view.dart';
import 'package:learning_dashboard/features/auth/domain/auth_repository.dart';
import 'package:learning_dashboard/features/courses/domain/course.dart';
import 'package:learning_dashboard/features/courses/domain/course_repository.dart';
import 'package:learning_dashboard/features/courses/presentation/dashboard/bloc/courses_bloc.dart';
import 'package:learning_dashboard/features/courses/presentation/dashboard/widgets/course_card.dart';
import 'package:learning_dashboard/l10n/l10n.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CoursesBloc(courseRepository: context.read<CourseRepository>())
            ..add(const CoursesFetchRequested()),
      child: const CoursesView(),
    );
  }
}

class CoursesView extends StatelessWidget {
  const CoursesView({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthRepository>().logout();
    if (context.mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.coursesTitle),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, state) {
          return switch (state.status) {
            CoursesStatus.initial || CoursesStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            CoursesStatus.failure => MessageView(
              icon: Icons.cloud_off_outlined,
              title: state.failure!.localizedMessage(l10n),
              actionLabel: l10n.retry,
              onAction: () => context.read<CoursesBloc>().add(
                const CoursesFetchRequested(),
              ),
            ),
            CoursesStatus.success => _CourseList(
              courses: state.courses,
              isOffline: state.isOffline,
            ),
          };
        },
      ),
    );
  }
}

class _CourseList extends StatelessWidget {
  const _CourseList({required this.courses, required this.isOffline});

  final List<Course> courses;
  final bool isOffline;

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<CoursesBloc>()
      ..add(const CoursesFetchRequested());
    await bloc.stream.firstWhere((state) => !state.isRefreshing);
  }

  Future<void> _openCourse(BuildContext context, Course course) async {
    await context.push(AppRoutes.courseDetail(course.id));
    if (context.mounted) {
      context.read<CoursesBloc>().add(const CoursesCacheReloadRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        if (isOffline) const _OfflineBanner(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: courses.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.6,
                        child: MessageView(
                          icon: Icons.inbox_outlined,
                          title: l10n.emptyCoursesTitle,
                          message: l10n.emptyCoursesMessage,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: courses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return CourseCard(
                        key: ValueKey(course.id),
                        course: course,
                        onContinue: () => _openCourse(context, course),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.wifi_off, size: 18, color: colors.onTertiaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.offlineBanner,
                style: TextStyle(color: colors.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
