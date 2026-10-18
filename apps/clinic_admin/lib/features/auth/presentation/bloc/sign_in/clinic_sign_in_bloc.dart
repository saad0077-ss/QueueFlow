import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/clinic_sign_in_usecase.dart';
import '../../../domain/usecases/reset_clinic_password_usecase.dart';
import 'clinic_sign_in_event.dart';
import 'clinic_sign_in_state.dart';

class ClinicSignInBloc extends Bloc<ClinicSignInEvent, ClinicSignInState> {
  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');

  final ClinicSignInUseCase signInUseCase;
  final ResetClinicPasswordUseCase resetPasswordUseCase;

  ClinicSignInBloc({
    required this.signInUseCase,
    required this.resetPasswordUseCase,
  }) : super(const ClinicSignInState()) {
    on<ClinicSignInEmailChanged>(_onEmailChanged);
    on<ClinicSignInPasswordChanged>(_onPasswordChanged);
    on<ClinicSignInTogglePassword>(_onTogglePassword);
    on<ClinicSignInSubmitted>(_onSubmitted);
    on<ClinicSignInForgotPasswordRequested>(_onForgotPassword);
  }

  void _onEmailChanged(
    ClinicSignInEmailChanged event,
    Emitter<ClinicSignInState> emit,
  ) {
    final trimmed = event.email.trim();
    final isValid = trimmed.isNotEmpty && _emailRegex.hasMatch(trimmed);
    String? inlineError;
    if (trimmed.isNotEmpty && trimmed.contains('@') && !isValid) {
      inlineError = 'Enter a valid email address.';
    }

    emit(state.copyWith(
      email: event.email,
      emailError: inlineError,
      clearEmailError: inlineError == null,
      isEmailValid: isValid,
      clearErrorMessage: true,
      clearInfoMessage: true,
    ));
  }

  void _onPasswordChanged(
    ClinicSignInPasswordChanged event,
    Emitter<ClinicSignInState> emit,
  ) {
    emit(state.copyWith(
      password: event.password,
      clearPasswordError: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    ));
  }

  void _onTogglePassword(
    ClinicSignInTogglePassword event,
    Emitter<ClinicSignInState> emit,
  ) {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  Future<void> _onSubmitted(
    ClinicSignInSubmitted event,
    Emitter<ClinicSignInState> emit,
  ) async {
    emit(state.copyWith(clearErrorMessage: true, clearInfoMessage: true));

    final email = state.email.trim();
    final password = state.password;

    String? emailError;
    String? passwordError;

    if (email.isEmpty || !_emailRegex.hasMatch(email)) {
      emailError = 'Enter a valid email address.';
    }
    if (password.isEmpty) {
      passwordError = 'Password is required.';
    }

    if (emailError != null || passwordError != null) {
      emit(state.copyWith(
        emailError: emailError,
        clearEmailError: emailError == null,
        isEmailValid: emailError == null,
        passwordError: passwordError,
        clearPasswordError: passwordError == null,
      ));
      return;
    }

    emit(state.copyWith(isLoading: true));
    try {
      final staff = await signInUseCase(email: email, password: password);
      emit(state.copyWith(isLoading: false, staff: staff));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onForgotPassword(
    ClinicSignInForgotPasswordRequested event,
    Emitter<ClinicSignInState> emit,
  ) async {
    emit(state.copyWith(clearErrorMessage: true, clearInfoMessage: true));
    final email = state.email.trim();
    if (email.isEmpty || !_emailRegex.hasMatch(email)) {
      emit(state.copyWith(
        emailError: 'Enter a valid email address.',
        errorMessage: 'Enter email first.',
      ));
      return;
    }
    try {
      await resetPasswordUseCase(email);
      emit(state.copyWith(infoMessage: 'Reset link sent.'));
    } catch (_) {
      emit(state.copyWith(infoMessage: 'Reset link sent.'));
    }
  }
}
