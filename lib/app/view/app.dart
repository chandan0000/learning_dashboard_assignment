import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_dashboard/app/router/app_router.dart';
import 'package:learning_dashboard/features/auth/domain/auth_repository.dart';
import 'package:learning_dashboard/features/courses/domain/course_repository.dart';
import 'package:learning_dashboard/l10n/l10n.dart';

class App extends StatefulWidget {
  const App({
    required this.authRepository,
    required this.courseRepository,
    required this.isLoggedIn,
    super.key,
  });

  final AuthRepository authRepository;
  final CourseRepository courseRepository;
  final bool isLoggedIn;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = createAppRouter(isLoggedIn: widget.isLoggedIn);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: widget.authRepository),
        RepositoryProvider<CourseRepository>.value(
          value: widget.courseRepository,
        ),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (context) => context.l10n.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        routerConfig: _router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
