import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/sign_in_usecase.dart';
import 'sign_in_event.dart';
import 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final SignInUseCase signInUseCase;
  final AuthRepository authRepository;

  SignInBloc({
    required this.signInUseCase,
    required this.authRepository,
  }) : super(const SignInState()) {
    on<SignInEmailChanged>((event, emit) {
      emit(state.copyWith(
        email: event.email,
        clearEmailError: true,
        clearErrorMessage: true,
      ));
    });

    on<SignInPasswordChanged>((event, emit) {
      emit(state.copyWith(
        password: event.password,
        clearErrorMessage: true,
      ));
    });

    on<SignInTogglePasswordVisibility>((event, emit) {
      emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
    });

    on<SignInSubmitted>(_onSignInSubmitted);
    on<SignInWithGoogleSubmitted>(_onGoogleSignInSubmitted);
  }

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    final email = state.email.trim();
    if (!email.contains('@') || !email.contains('.')) {
      emit(state.copyWith(emailError: 'Enter a valid email address.'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    try {
      final user = await signInUseCase(
        email: email,
        password: state.password,
      );
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onGoogleSignInSubmitted(
    SignInWithGoogleSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    try {
      final user = await authRepository.signInWithGoogle();
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
