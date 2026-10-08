import 'package:go_router/go_router.dart';
import 'package:learning_dashboard/features/auth/presentation/view/login_page.dart';
import 'package:learning_dashboard/features/courses/presentation/dashboard/view/courses_page.dart';
import 'package:learning_dashboard/features/courses/presentation/detail/view/course_detail_page.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const courses = '/courses';
  static String courseDetail(int courseId) => '$courses/$courseId';
}

GoRouter createAppRouter({required bool isLoggedIn}) {
  return GoRouter(
    initialLocation: isLoggedIn ? AppRoutes.courses : AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.courses,
        builder: (context, state) => const CoursesPage(),
        routes: [
          GoRoute(
            path: ':courseId',
            builder: (context, state) {
              final courseId =
                  int.tryParse(state.pathParameters['courseId'] ?? '') ?? -1;
              return CourseDetailPage(courseId: courseId);
            },
          ),
        ],
      ),
    ],
  );
}
