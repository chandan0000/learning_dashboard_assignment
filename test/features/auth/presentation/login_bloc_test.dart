import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/features/auth/domain/auth_repository.dart';
import 'package:learning_dashboard/features/auth/domain/credentials_validator.dart';
import 'package:learning_dashboard/features/auth/presentation/bloc/login_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  setUp(() => repository = _MockAuthRepository());

  LoginBloc buildBloc() => LoginBloc(authRepository: repository);

  void stubLogin(Future<void> Function() answer) => when(
    () => repository.login(
      email: any(named: 'email'),
      password: any(named: 'password'),
    ),
  ).thenAnswer((_) => answer());

  blocTest<LoginBloc, LoginState>(
    'shows validation errors and never calls the API for invalid input',
    build: buildBloc,
    act: (bloc) => bloc
      ..add(const LoginEmailChanged('not-an-email'))
      ..add(const LoginPasswordChanged('123'))
      ..add(const LoginSubmitted()),
    verify: (bloc) {
      expect(bloc.state.emailError, EmailError.invalid);
      expect(bloc.state.passwordError, PasswordError.tooShort);
      verifyNever(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    },
  );

  blocTest<LoginBloc, LoginState>(
    'emits [submitting, success] for valid credentials',
    setUp: () => stubLogin(() async {}),
    build: buildBloc,
    seed: () => const LoginState(email: ' a@b.com ', password: 'password123'),
    act: (bloc) => bloc.add(const LoginSubmitted()),
    expect: () => const [
      LoginState(
        email: ' a@b.com ',
        password: 'password123',
        status: LoginStatus.submitting,
        showValidationErrors: true,
      ),
      LoginState(
        email: ' a@b.com ',
        password: 'password123',
        status: LoginStatus.success,
        showValidationErrors: true,
      ),
    ],
    verify: (_) => verify(
      () => repository.login(email: 'a@b.com', password: 'password123'),
    ).called(1),
  );

  blocTest<LoginBloc, LoginState>(
    'emits failure with the reason when the API rejects the login',
    setUp: () =>
        stubLogin(() => Future.error(const InvalidCredentialsException())),
    build: buildBloc,
    seed: () => const LoginState(email: 'a@b.com', password: 'wrong-pass'),
    act: (bloc) => bloc.add(const LoginSubmitted()),
    skip: 1,
    expect: () => const [
      LoginState(
        email: 'a@b.com',
        password: 'wrong-pass',
        status: LoginStatus.failure,
        showValidationErrors: true,
        failure: InvalidCredentialsException(),
      ),
    ],
  );
}
