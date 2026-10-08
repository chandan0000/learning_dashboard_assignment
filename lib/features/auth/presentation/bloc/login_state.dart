part of 'login_bloc.dart';

enum LoginStatus { idle, submitting, success, failure }

final class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.status = LoginStatus.idle,
    this.showValidationErrors = false,
    this.failure,
  });

  final String email;
  final String password;
  final LoginStatus status;

  final bool showValidationErrors;

  final AppException? failure;

  EmailError? get emailError =>
      showValidationErrors ? CredentialsValidator.validateEmail(email) : null;

  PasswordError? get passwordError => showValidationErrors
      ? CredentialsValidator.validatePassword(password)
      : null;

  bool get isFormValid =>
      CredentialsValidator.validateEmail(email) == null &&
      CredentialsValidator.validatePassword(password) == null;

  bool get isSubmitting => status == LoginStatus.submitting;

  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    bool? showValidationErrors,
    AppException? failure,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    status,
    showValidationErrors,
    failure,
  ];
}
