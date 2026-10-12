import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

class SignInState extends Equatable {
  final String email;
  final String password;
  final bool isPasswordObscured;
  final bool isLoading;
  final String? emailError;
  final String? errorMessage;
  final UserEntity? user;

  const SignInState({
    this.email = '',
    this.password = '',
    this.isPasswordObscured = true,
    this.isLoading = false,
    this.emailError,
    this.errorMessage,
    this.user,
  });

  SignInState copyWith({
    String? email,
    String? password,
    bool? isPasswordObscured,
    bool? isLoading,
    String? emailError,
    bool clearEmailError = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    UserEntity? user,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isLoading: isLoading ?? this.isLoading,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        isPasswordObscured,
        isLoading,
        emailError,
        errorMessage,
        user,
      ];
}
