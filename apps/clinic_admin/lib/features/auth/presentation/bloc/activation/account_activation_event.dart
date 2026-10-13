import 'package:equatable/equatable.dart';

abstract class AccountActivationEvent extends Equatable {
  const AccountActivationEvent();

  @override
  List<Object?> get props => [];
}

class ActivationPasswordChanged extends AccountActivationEvent {
  final String password;
  const ActivationPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class ActivationConfirmPasswordChanged extends AccountActivationEvent {
  final String confirmPassword;
  const ActivationConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class ActivationTogglePassword extends AccountActivationEvent {
  const ActivationTogglePassword();
}

class ActivationToggleConfirmPassword extends AccountActivationEvent {
  const ActivationToggleConfirmPassword();
}

class ActivationToggleTerms extends AccountActivationEvent {
  final bool agreed;
  const ActivationToggleTerms(this.agreed);

  @override
  List<Object?> get props => [agreed];
}

class ActivationSubmitted extends AccountActivationEvent {
  const ActivationSubmitted();
}
