import 'package:equatable/equatable.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();
  @override
  List<Object?> get props => [];
}

class UpdateNameEvent extends EditProfileEvent {
  final String name;
  const UpdateNameEvent(this.name);
  @override
  List<Object?> get props => [name];
}

class UpdateAgeEvent extends EditProfileEvent {
  final String age;
  const UpdateAgeEvent(this.age);
  @override
  List<Object?> get props => [age];
}

class UpdateEmailEvent extends EditProfileEvent {
  final String email;
  const UpdateEmailEvent(this.email);
  @override
  List<Object?> get props => [email];
}

class UpdatePhoneEvent extends EditProfileEvent {
  final String phone;
  const UpdatePhoneEvent(this.phone);
  @override
  List<Object?> get props => [phone];
}

class UpdateGenderEvent extends EditProfileEvent {
  final String? gender;
  const UpdateGenderEvent(this.gender);
  @override
  List<Object?> get props => [gender];
}

class UpdateBloodGroupEvent extends EditProfileEvent {
  final String? bloodGroup;
  const UpdateBloodGroupEvent(this.bloodGroup);
  @override
  List<Object?> get props => [bloodGroup];
}

class UpdatePhotoEvent extends EditProfileEvent {
  final String? photoBase64;
  const UpdatePhotoEvent(this.photoBase64);
  @override
  List<Object?> get props => [photoBase64];
}

class RemovePhotoEvent extends EditProfileEvent {
  const RemovePhotoEvent();
}

class SetPickingPhotoEvent extends EditProfileEvent {
  final bool isPicking;
  const SetPickingPhotoEvent(this.isPicking);
  @override
  List<Object?> get props => [isPicking];
}
