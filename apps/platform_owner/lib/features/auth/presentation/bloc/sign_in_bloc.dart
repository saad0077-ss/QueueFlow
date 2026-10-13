import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import 'sign_in_event.dart';
import 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  static const String _adminDomain = '@queueflow.com';
  static const String _masterAdminEmail = 'admin@queueflow.com';
  static final RegExp _emailRegex =
      RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');

  final SignInUseCase signInUseCase;

  SignInBloc({required this.signInUseCase}) : super(const SignInState()) {
    on<SignInEmailChanged>(_onEmailChanged);
    on<SignInPasswordChanged>(_onPasswordChanged);
    on<SignInTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<SignInSubmitted>(_onSignInSubmitted);
  }

  void _onEmailChanged(SignInEmailChanged event, Emitter<SignInState> emit) {
    final trimmed = event.email.trim().toLowerCase();
    String? inlineEmailError;
    bool isEmailValid = false;

    if (trimmed.isNotEmpty && _emailRegex.hasMatch(trimmed)) {
      if (trimmed.endsWith(_adminDomain)) {
        isEmailValid = true;
      } else {
        inlineEmailError = 'Email must end with @queueflow.com';
      }
    }

    emit(state.copyWith(
      email: event.email,
      emailError: inlineEmailError,
      clearEmailError: inlineEmailError == null,
      isEmailValid: isEmailValid,
      clearErrorMessage: true,
    ));
  }

  void _onPasswordChanged(
    SignInPasswordChanged event,
    Emitter<SignInState> emit,
  ) {
    emit(state.copyWith(
      password: event.password,
      clearPasswordError: true,
      clearErrorMessage: true,
    ));
  }

  void _onTogglePasswordVisibility(
    SignInTogglePasswordVisibility event,
    Emitter<SignInState> emit,
  ) {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    emit(state.copyWith(clearErrorMessage: true));

    final email = state.email.trim().toLowerCase();
    final password = state.password;

    String? emailError;
    String? passwordError;
    String? snackBarError;

    if (email.isEmpty) {
      emailError = 'Email address is required.';
    } else if (!_emailRegex.hasMatch(email)) {
      emailError = 'Enter a valid email address (e.g. admin@queueflow.com).';
    } else if (!email.endsWith(_adminDomain)) {
      emailError = 'Email must follow @queueflow.com domain.';
      snackBarError = 'Only admin has access.';
    } else if (email != _masterAdminEmail) {
      emailError = 'Unauthorized @queueflow.com account.';
      snackBarError = 'Only admin has access.';
    }

    if (password.isEmpty) {
      passwordError = 'Password is required.';
    } else if (password.length < 6) {
      passwordError = 'Password must be at least 6 characters.';
    }

    if (emailError != null || passwordError != null) {
      emit(state.copyWith(
        emailError: emailError,
        clearEmailError: emailError == null,
        isEmailValid: emailError == null && email.endsWith(_adminDomain),
        passwordError: passwordError,
        clearPasswordError: passwordError == null,
        errorMessage: snackBarError,
      ));
      return;
    }

    emit(state.copyWith(
      isLoading: true,
      clearEmailError: true,
      isEmailValid: true,
      clearPasswordError: true,
      clearErrorMessage: true,
    ));

    try {
      final admin = await signInUseCase(email: email, password: password);
      emit(state.copyWith(isLoading: false, admin: admin));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
