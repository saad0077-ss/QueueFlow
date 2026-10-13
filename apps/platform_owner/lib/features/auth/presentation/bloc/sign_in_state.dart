import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_entity.dart';

class SignInState extends Equatable {
  final String email;
  final String password;
  final String? emailError;
  final bool isEmailValid;
  final String? passwordError;
  final bool isPasswordObscured;
  final bool isLoading;
  final String? errorMessage;
  final AdminEntity? admin;

  const SignInState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.isEmailValid = false,
    this.passwordError,
    this.isPasswordObscured = true,
    this.isLoading = false,
    this.errorMessage,
    this.admin,
  });

  SignInState copyWith({
    String? email,
    String? password,
    String? emailError,
    bool clearEmailError = false,
    bool? isEmailValid,
    String? passwordError,
    bool clearPasswordError = false,
    bool? isPasswordObscured,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    AdminEntity? admin,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      isEmailValid: isEmailValid ?? this.isEmailValid,
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      admin: admin ?? this.admin,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        emailError,
        isEmailValid,
        passwordError,
        isPasswordObscured,
        isLoading,
        errorMessage,
        admin,
      ];
}
