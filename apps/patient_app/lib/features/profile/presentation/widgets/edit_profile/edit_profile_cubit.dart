import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/patient_profile_entity.dart';

class EditProfileState extends Equatable {
  final String name;
  final String ageText;
  final String email;
  final String phone;
  final String? gender;
  final String? bloodGroup;
  final String? photoBase64;
  final bool isPickingPhoto;

  const EditProfileState({
    required this.name,
    required this.ageText,
    required this.email,
    required this.phone,
    this.gender,
    this.bloodGroup,
    this.photoBase64,
    this.isPickingPhoto = false,
  });

  String computeInitials(String fallback) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return fallback;
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first
        .substring(0, parts.first.length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  int? get parsedAge => int.tryParse(ageText.trim());

  EditProfileState copyWith({
    String? name,
    String? ageText,
    String? email,
    String? phone,
    String? gender,
    String? bloodGroup,
    String? photoBase64,
    bool clearPhoto = false,
    bool? isPickingPhoto,
  }) {
    return EditProfileState(
      name: name ?? this.name,
      ageText: ageText ?? this.ageText,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      photoBase64: clearPhoto ? null : (photoBase64 ?? this.photoBase64),
      isPickingPhoto: isPickingPhoto ?? this.isPickingPhoto,
    );
  }

  @override
  List<Object?> get props => [
        name,
        ageText,
        email,
        phone,
        gender,
        bloodGroup,
        photoBase64,
        isPickingPhoto,
      ];
}

class EditProfileCubit extends Cubit<EditProfileState> {
  final PatientProfileEntity initialProfile;

  EditProfileCubit(this.initialProfile)
      : super(EditProfileState(
          name: initialProfile.name,
          ageText: initialProfile.age?.toString() ?? '',
          email: initialProfile.email,
          phone: initialProfile.phone,
          gender: initialProfile.gender,
          bloodGroup: initialProfile.bloodGroup,
          photoBase64: initialProfile.photoBase64,
        ));

  void updateName(String val) => emit(state.copyWith(name: val));
  void updateAge(String val) => emit(state.copyWith(ageText: val));
  void updateEmail(String val) => emit(state.copyWith(email: val));
  void updatePhone(String val) => emit(state.copyWith(phone: val));
  void updateGender(String? val) => emit(state.copyWith(gender: val));
  void updateBloodGroup(String? val) => emit(state.copyWith(bloodGroup: val));
  void updatePhoto(String? base64) => emit(state.copyWith(photoBase64: base64));
  void removePhoto() => emit(state.copyWith(clearPhoto: true));
  void setPickingPhoto(bool picking) =>
      emit(state.copyWith(isPickingPhoto: picking));
}
