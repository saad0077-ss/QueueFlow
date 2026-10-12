import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

class SignUpFullNameChanged extends SignUpEvent {
  final String fullName;
  const SignUpFullNameChanged(this.fullName);

  @override
  List<Object?> get props => [fullName];
}

class SignUpEmailChanged extends SignUpEvent {
  final String email;
  const SignUpEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class SignUpPhoneChanged extends SignUpEvent {
  final String phone;
  const SignUpPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

class SignUpPasswordChanged extends SignUpEvent {
  final String password;
  const SignUpPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class SignUpConfirmPasswordChanged extends SignUpEvent {
  final String confirmPassword;
  const SignUpConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class SignUpTogglePasswordVisibility extends SignUpEvent {
  const SignUpTogglePasswordVisibility();
}

class SignUpToggleConfirmVisibility extends SignUpEvent {
  const SignUpToggleConfirmVisibility();
}

class SignUpSubmitted extends SignUpEvent {
  const SignUpSubmitted();
}
