import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/activate_clinic_account_usecase.dart';
import 'account_activation_event.dart';
import 'account_activation_state.dart';

class AccountActivationBloc
    extends Bloc<AccountActivationEvent, AccountActivationState> {
  final ActivateClinicAccountUseCase activateUseCase;

  AccountActivationBloc({
    required this.activateUseCase,
    String? initialEmail,
    String? initialDoctorName,
    String? initialClinicName,
    String? initialRole,
  }) : super(AccountActivationState(
          inviteEmail: (initialEmail != null && initialEmail.isNotEmpty)
              ? initialEmail
              : 'admin@clinic.com',
          doctorName: (initialDoctorName != null && initialDoctorName.isNotEmpty)
              ? initialDoctorName
              : 'Clinic Admin',
          clinicName: (initialClinicName != null && initialClinicName.isNotEmpty)
              ? initialClinicName
              : 'Healthcare Clinic',
          role: (initialRole != null && initialRole.isNotEmpty)
              ? initialRole
              : 'Clinic Admin',
        )) {
    on<ActivationPasswordChanged>(_onPasswordChanged);
    on<ActivationConfirmPasswordChanged>(_onConfirmChanged);
    on<ActivationTogglePassword>(_onTogglePassword);
    on<ActivationToggleConfirmPassword>(_onToggleConfirm);
    on<ActivationToggleTerms>(_onToggleTerms);
    on<ActivationSubmitted>(_onSubmitted);
  }

  double _calculateStrength(String value) {
    if (value.isEmpty) return 0.0;
    double score = 0.0;
    if (value.length >= 8) score += 0.4;
    if (RegExp(r'[A-Z]').hasMatch(value)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(value)) score += 0.2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score += 0.2;
    return score.clamp(0.15, 1.0);
  }

  void _onPasswordChanged(
    ActivationPasswordChanged event,
    Emitter<AccountActivationState> emit,
  ) {
    final pwd = event.password;
    final strength = _calculateStrength(pwd);
    final hasConfirm = state.confirmPassword.isNotEmpty;
    final matches = hasConfirm && state.confirmPassword == pwd;

    emit(state.copyWith(
      password: pwd,
      passwordStrength: strength,
      clearPasswordError: true,
      confirmError: (hasConfirm && !matches) ? "Passwords don't match." : null,
      clearConfirmError: !hasConfirm || matches,
      isConfirmValid: matches && pwd.length >= 8,
      clearErrorMessage: true,
    ));
  }

  void _onConfirmChanged(
    ActivationConfirmPasswordChanged event,
    Emitter<AccountActivationState> emit,
  ) {
    final confirm = event.confirmPassword;
    final matches = confirm.isNotEmpty && confirm == state.password;

    emit(state.copyWith(
      confirmPassword: confirm,
      confirmError:
          (confirm.isNotEmpty && !matches) ? "Passwords don't match." : null,
      clearConfirmError: confirm.isEmpty || matches,
      isConfirmValid: matches && state.password.length >= 8,
      clearErrorMessage: true,
    ));
  }

  void _onTogglePassword(
    ActivationTogglePassword event,
    Emitter<AccountActivationState> emit,
  ) {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  void _onToggleConfirm(
    ActivationToggleConfirmPassword event,
    Emitter<AccountActivationState> emit,
  ) {
    emit(state.copyWith(isConfirmObscured: !state.isConfirmObscured));
  }

  void _onToggleTerms(
    ActivationToggleTerms event,
    Emitter<AccountActivationState> emit,
  ) {
    emit(state.copyWith(agreedToTerms: event.agreed, clearErrorMessage: true));
  }

  Future<void> _onSubmitted(
    ActivationSubmitted event,
    Emitter<AccountActivationState> emit,
  ) async {
    emit(state.copyWith(clearErrorMessage: true));

    if (state.password.length < 8) {
      emit(state.copyWith(passwordError: 'At least 8 characters required.'));
      return;
    }
    if (state.confirmPassword != state.password) {
      emit(state.copyWith(
        confirmError: "Passwords don't match.",
        isConfirmValid: false,
      ));
      return;
    }
    if (!state.agreedToTerms) {
      emit(state.copyWith(errorMessage: 'Please accept Terms of Service.'));
      return;
    }

    emit(state.copyWith(isLoading: true));
    try {
      final staff = await activateUseCase(
        email: state.inviteEmail,
        password: state.password,
        doctorName: state.doctorName,
        role: state.role,
        clinicName: state.clinicName,
      );
      emit(state.copyWith(isLoading: false, activatedStaff: staff));
    } catch (e) {
      String msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.contains('malformed or has expired') || msg.contains('invalid-credential')) {
        msg = 'An account with this email is already registered with a different password. Please log in or use "Forgot password" to reset it.';
      }
      emit(state.copyWith(
        isLoading: false,
        errorMessage: msg,
      ));
    }
  }
}
