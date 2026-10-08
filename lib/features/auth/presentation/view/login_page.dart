import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_dashboard/app/router/app_router.dart';
import 'package:learning_dashboard/core/error/error_message.dart';
import 'package:learning_dashboard/features/auth/domain/auth_repository.dart';
import 'package:learning_dashboard/features/auth/domain/credentials_validator.dart';
import 'package:learning_dashboard/features/auth/presentation/bloc/login_bloc.dart';
import 'package:learning_dashboard/l10n/l10n.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoginBloc(authRepository: context.read<AuthRepository>()),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case LoginStatus.success:
            context.go(AppRoutes.courses);
          case LoginStatus.failure:
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.failure!.localizedMessage(l10n))),
              );
          case LoginStatus.idle:
          case LoginStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(),
                    SizedBox(height: 32),
                    _EmailField(),
                    SizedBox(height: 16),
                    _PasswordField(),
                    SizedBox(height: 24),
                    _LoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(
          Icons.school_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(context.l10n.loginTitle, style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(context.l10n.loginSubtitle, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (error, enabled) = context.select<LoginBloc, (EmailError?, bool)>(
      (bloc) => (bloc.state.emailError, !bloc.state.isSubmitting),
    );

    return TextField(
      key: const Key('login_email_field'),
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      onChanged: (value) =>
          context.read<LoginBloc>().add(LoginEmailChanged(value)),
      decoration: InputDecoration(
        labelText: l10n.emailLabel,
        prefixIcon: const Icon(Icons.email_outlined),
        border: const OutlineInputBorder(),
        errorText: switch (error) {
          EmailError.empty => l10n.emailRequired,
          EmailError.invalid => l10n.emailInvalid,
          null => null,
        },
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField();

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (error, enabled) = context.select<LoginBloc, (PasswordError?, bool)>(
      (bloc) => (bloc.state.passwordError, !bloc.state.isSubmitting),
    );

    return TextField(
      key: const Key('login_password_field'),
      enabled: enabled,
      obscureText: _obscured,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      onChanged: (value) =>
          context.read<LoginBloc>().add(LoginPasswordChanged(value)),
      onSubmitted: (_) => context.read<LoginBloc>().add(const LoginSubmitted()),
      decoration: InputDecoration(
        labelText: l10n.passwordLabel,
        prefixIcon: const Icon(Icons.lock_outline),
        border: const OutlineInputBorder(),
        errorText: switch (error) {
          PasswordError.empty => l10n.passwordRequired,
          PasswordError.tooShort => l10n.passwordTooShort(
            CredentialsValidator.minPasswordLength,
          ),
          null => null,
        },
        suffixIcon: IconButton(
          icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select<LoginBloc, bool>(
      (bloc) => bloc.state.isSubmitting,
    );

    return FilledButton(
      key: const Key('login_submit_button'),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      onPressed: isSubmitting
          ? null
          : () {
              FocusScope.of(context).unfocus();
              context.read<LoginBloc>().add(const LoginSubmitted());
            },
      child: isSubmitting
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Text(context.l10n.loginButton),
    );
  }
}
