import 'package:equatable/equatable.dart';

abstract class ClinicSignInEvent extends Equatable {
  const ClinicSignInEvent();

  @override
  List<Object?> get props => [];
}

class ClinicSignInEmailChanged extends ClinicSignInEvent {
  final String email;
  const ClinicSignInEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class ClinicSignInPasswordChanged extends ClinicSignInEvent {
  final String password;
  const ClinicSignInPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class ClinicSignInTogglePassword extends ClinicSignInEvent {
  const ClinicSignInTogglePassword();
}

class ClinicSignInSubmitted extends ClinicSignInEvent {
  const ClinicSignInSubmitted();
}

class ClinicSignInForgotPasswordRequested extends ClinicSignInEvent {
  const ClinicSignInForgotPasswordRequested();
}
