import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/sign_up_usecase.dart';
import 'sign_up_event.dart';
import 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpUseCase signUpUseCase;

  SignUpBloc({required this.signUpUseCase}) : super(const SignUpState()) {
    on<SignUpFullNameChanged>((event, emit) {
      emit(state.copyWith(fullName: event.fullName, clearErrorMessage: true));
    });

    on<SignUpEmailChanged>((event, emit) {
      emit(state.copyWith(
        email: event.email,
        clearEmailError: true,
        clearErrorMessage: true,
      ));
    });

    on<SignUpPhoneChanged>((event, emit) {
      emit(state.copyWith(phoneNumber: event.phone, clearErrorMessage: true));
    });

    on<SignUpPasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password, clearErrorMessage: true));
    });

    on<SignUpConfirmPasswordChanged>((event, emit) {
      emit(state.copyWith(
        confirmPassword: event.confirmPassword,
        clearConfirmError: true,
        clearErrorMessage: true,
      ));
    });

    on<SignUpTogglePasswordVisibility>((event, emit) {
      emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
    });

    on<SignUpToggleConfirmVisibility>((event, emit) {
      emit(state.copyWith(isConfirmObscured: !state.isConfirmObscured));
    });

    on<SignUpSubmitted>(_onSignUpSubmitted);
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    final email = state.email.trim();
    bool hasError = false;

    if (!email.contains('@') || !email.contains('.')) {
      emit(state.copyWith(emailError: 'Enter a valid email address.'));
      hasError = true;
    }

    if (state.password.isNotEmpty &&
        state.confirmPassword.isNotEmpty &&
        state.password != state.confirmPassword) {
      emit(state.copyWith(confirmPasswordError: "Passwords don't match."));
      hasError = true;
    }

    if (hasError) return;

    emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    try {
      final user = await signUpUseCase(
        fullName: state.fullName,
        email: email,
        phoneNumber: state.phoneNumber,
        password: state.password,
      );
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
