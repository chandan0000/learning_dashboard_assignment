import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/features/auth/domain/auth_repository.dart';
import 'package:learning_dashboard/features/auth/domain/credentials_validator.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required this._authRepository}) : super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  final AuthRepository _authRepository;

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email, status: LoginStatus.idle));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password, status: LoginStatus.idle));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isSubmitting) return;

    if (!state.isFormValid) {
      emit(state.copyWith(showValidationErrors: true));
      return;
    }

    emit(
      state.copyWith(
        status: LoginStatus.submitting,
        showValidationErrors: true,
      ),
    );
    try {
      await _authRepository.login(
        email: state.email.trim(),
        password: state.password,
      );
      emit(state.copyWith(status: LoginStatus.success));
    } on AppException catch (error) {
      emit(state.copyWith(status: LoginStatus.failure, failure: error));
    }
  }
}
