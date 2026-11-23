import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/patient_profile_entity.dart';
import 'edit_profile_event.dart';

export 'edit_profile_event.dart';

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

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final PatientProfileEntity initialProfile;

  EditProfileBloc(this.initialProfile)
    : super(
        EditProfileState(
          name: initialProfile.name,
          ageText: initialProfile.age?.toString() ?? '',
          email: initialProfile.email,
          phone: initialProfile.phone,
          gender: initialProfile.gender,
          bloodGroup: initialProfile.bloodGroup,
          photoBase64: initialProfile.photoBase64,
        ),
      ) {
    on<UpdateNameEvent>((e, emit) => emit(state.copyWith(name: e.name)));
    on<UpdateAgeEvent>((e, emit) => emit(state.copyWith(ageText: e.age)));
    on<UpdateEmailEvent>((e, emit) => emit(state.copyWith(email: e.email)));
    on<UpdatePhoneEvent>((e, emit) => emit(state.copyWith(phone: e.phone)));
    on<UpdateGenderEvent>((e, emit) => emit(state.copyWith(gender: e.gender)));
    on<UpdateBloodGroupEvent>(
      (e, emit) => emit(state.copyWith(bloodGroup: e.bloodGroup)),
    );
    on<UpdatePhotoEvent>(
      (e, emit) => emit(state.copyWith(photoBase64: e.photoBase64)),
    );
    on<RemovePhotoEvent>((e, emit) => emit(state.copyWith(clearPhoto: true)));
    on<SetPickingPhotoEvent>(
      (e, emit) => emit(state.copyWith(isPickingPhoto: e.isPicking)),
    );
  }

  void updateName(String val) => add(UpdateNameEvent(val));
  void updateAge(String val) => add(UpdateAgeEvent(val));
  void updateEmail(String val) => add(UpdateEmailEvent(val));
  void updatePhone(String val) => add(UpdatePhoneEvent(val));
  void updateGender(String? val) => add(UpdateGenderEvent(val));
  void updateBloodGroup(String? val) => add(UpdateBloodGroupEvent(val));
  void updatePhoto(String? base64) => add(UpdatePhotoEvent(base64));
  void removePhoto() => add(const RemovePhotoEvent());
  void setPickingPhoto(bool picking) => add(SetPickingPhotoEvent(picking));
}
