import 'package:equatable/equatable.dart';
import '../../../domain/entities/clinic_staff_entity.dart';

class AccountActivationState extends Equatable {
  final String inviteEmail;
  final String doctorName;
  final String role;
  final String clinicName;
  final String password;
  final String confirmPassword;
  final bool isPasswordObscured;
  final bool isConfirmObscured;
  final bool agreedToTerms;
  final double passwordStrength;
  final String? passwordError;
  final String? confirmError;
  final bool isConfirmValid;
  final bool isLoading;
  final String? errorMessage;
  final ClinicStaffEntity? activatedStaff;

  const AccountActivationState({
    this.inviteEmail = 'priya@sunrisehealth.com',
    this.doctorName = 'Dr. Priya',
    this.role = 'Clinic Admin',
    this.clinicName = 'Sunrise Health Clinic',
    this.password = '',
    this.confirmPassword = '',
    this.isPasswordObscured = true,
    this.isConfirmObscured = true,
    this.agreedToTerms = false,
    this.passwordStrength = 0.0,
    this.passwordError,
    this.confirmError,
    this.isConfirmValid = false,
    this.isLoading = false,
    this.errorMessage,
    this.activatedStaff,
  });

  AccountActivationState copyWith({
    String? password,
    String? confirmPassword,
    bool? isPasswordObscured,
    bool? isConfirmObscured,
    bool? agreedToTerms,
    double? passwordStrength,
    String? passwordError,
    bool clearPasswordError = false,
    String? confirmError,
    bool clearConfirmError = false,
    bool? isConfirmValid,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    ClinicStaffEntity? activatedStaff,
  }) {
    return AccountActivationState(
      inviteEmail: inviteEmail,
      doctorName: doctorName,
      role: role,
      clinicName: clinicName,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isConfirmObscured: isConfirmObscured ?? this.isConfirmObscured,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      passwordStrength: passwordStrength ?? this.passwordStrength,
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
      confirmError:
          clearConfirmError ? null : (confirmError ?? this.confirmError),
      isConfirmValid: isConfirmValid ?? this.isConfirmValid,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      activatedStaff: activatedStaff ?? this.activatedStaff,
    );
  }

  @override
  List<Object?> get props => [
        inviteEmail,
        doctorName,
        role,
        clinicName,
        password,
        confirmPassword,
        isPasswordObscured,
        isConfirmObscured,
        agreedToTerms,
        passwordStrength,
        passwordError,
        confirmError,
        isConfirmValid,
        isLoading,
        errorMessage,
        activatedStaff,
      ];
}
