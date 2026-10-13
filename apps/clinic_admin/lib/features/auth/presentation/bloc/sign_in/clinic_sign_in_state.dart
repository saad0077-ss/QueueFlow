import 'package:equatable/equatable.dart';
import '../../../domain/entities/clinic_staff_entity.dart';

class ClinicSignInState extends Equatable {
  final String email;
  final String password;
  final String? emailError;
  final bool isEmailValid;
  final String? passwordError;
  final bool isPasswordObscured;
  final bool isLoading;
  final String? errorMessage;
  final String? infoMessage;
  final ClinicStaffEntity? staff;

  const ClinicSignInState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.isEmailValid = false,
    this.passwordError,
    this.isPasswordObscured = true,
    this.isLoading = false,
    this.errorMessage,
    this.infoMessage,
    this.staff,
  });

  ClinicSignInState copyWith({
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
    String? infoMessage,
    bool clearInfoMessage = false,
    ClinicStaffEntity? staff,
  }) {
    return ClinicSignInState(
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
      infoMessage: clearInfoMessage ? null : (infoMessage ?? this.infoMessage),
      staff: staff ?? this.staff,
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
        infoMessage,
        staff,
      ];
}
