import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:learning_dashboard/app/app.dart';
import 'package:learning_dashboard/core/database/app_database.dart';
import 'package:learning_dashboard/core/network/network_info.dart';
import 'package:learning_dashboard/core/storage/token_storage.dart';
import 'package:learning_dashboard/features/auth/data/auth_api.dart';
import 'package:learning_dashboard/features/auth/data/auth_repository_impl.dart';
import 'package:learning_dashboard/features/courses/data/course_api.dart';
import 'package:learning_dashboard/features/courses/data/course_local_data_source.dart';
import 'package:learning_dashboard/features/courses/data/course_repository_impl.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };
  Bloc.observer = const AppBlocObserver();

  const networkInfo = DnsNetworkInfo();
  final database = await AppDatabase.open();
  final tokenStorage = SecureTokenStorage();

  final authRepository = AuthRepositoryImpl(
    api: MockAuthApi(networkInfo: networkInfo),
    tokenStorage: tokenStorage,
  );
  final courseRepository = CourseRepositoryImpl(
    api: MockCourseApi(networkInfo: networkInfo),
    localDataSource: SqfliteCourseLocalDataSource(database),
  );

  runApp(
    App(
      authRepository: authRepository,
      courseRepository: courseRepository,
      isLoggedIn: await authRepository.isLoggedIn(),
    ),
  );
}
