import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

class SignUpState extends Equatable {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final bool isPasswordObscured;
  final bool isConfirmObscured;
  final bool isLoading;
  final String? emailError;
  final String? confirmPasswordError;
  final String? errorMessage;
  final UserEntity? user;

  const SignUpState({
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.password = '',
    this.confirmPassword = '',
    this.isPasswordObscured = true,
    this.isConfirmObscured = true,
    this.isLoading = false,
    this.emailError,
    this.confirmPasswordError,
    this.errorMessage,
    this.user,
  });

  SignUpState copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? password,
    String? confirmPassword,
    bool? isPasswordObscured,
    bool? isConfirmObscured,
    bool? isLoading,
    String? emailError,
    bool clearEmailError = false,
    String? confirmPasswordError,
    bool clearConfirmError = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    UserEntity? user,
  }) {
    return SignUpState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isConfirmObscured: isConfirmObscured ?? this.isConfirmObscured,
      isLoading: isLoading ?? this.isLoading,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      confirmPasswordError: clearConfirmError
          ? null
          : (confirmPasswordError ?? this.confirmPasswordError),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        email,
        phoneNumber,
        password,
        confirmPassword,
        isPasswordObscured,
        isConfirmObscured,
        isLoading,
        emailError,
        confirmPasswordError,
        errorMessage,
        user,
      ];
}
