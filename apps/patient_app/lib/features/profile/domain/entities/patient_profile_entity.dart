import 'package:equatable/equatable.dart';

class PatientProfileEntity extends Equatable {
  final String id;
  final String name;
  final String initials;
  final String email;
  final String phone;
  final String healthId;
  final String? bloodGroup;
  final String? photoBase64;
  final String dob;
  final int? age;
  final String? gender;
  final String memberSince;
  final int loyaltyCredits;
  final String emergencyContactName;
  final String emergencyContactRelation;
  final String emergencyContactPhone;
  final String bp;
  final String sugar;
  final String weight;
  final String height;
  final String bmi;
  final List<String> allergies;
  final String insuranceProvider;
  final String insurancePolicyNo;
  final String insuranceValidTill;
  final String insuranceCoverage;
  final bool darkMode;
  final int visitsCount;
  final int favoritesCount;
  final int reviewsCount;

  const PatientProfileEntity({
    required this.id,
    required this.name,
    required this.initials,
    required this.email,
    required this.phone,
    required this.healthId,
    this.bloodGroup,
    this.photoBase64,
    required this.dob,
    this.age,
    this.gender,
    required this.memberSince,
    required this.loyaltyCredits,
    required this.emergencyContactName,
    required this.emergencyContactRelation,
    required this.emergencyContactPhone,
    required this.bp,
    required this.sugar,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.allergies,
    required this.insuranceProvider,
    required this.insurancePolicyNo,
    required this.insuranceValidTill,
    required this.insuranceCoverage,
    this.darkMode = false,
    this.visitsCount = 0,
    this.favoritesCount = 0,
    this.reviewsCount = 2,
  });

  PatientProfileEntity copyWith({
    String? id,
    String? name,
    String? initials,
    String? email,
    String? phone,
    String? healthId,
    String? bloodGroup,
    String? photoBase64,
    String? dob,
    int? age,
    String? gender,
    String? memberSince,
    int? loyaltyCredits,
    String? emergencyContactName,
    String? emergencyContactRelation,
    String? emergencyContactPhone,
    String? bp,
    String? sugar,
    String? weight,
    String? height,
    String? bmi,
    List<String>? allergies,
    String? insuranceProvider,
    String? insurancePolicyNo,
    String? insuranceValidTill,
    String? insuranceCoverage,
    bool? darkMode,
    int? visitsCount,
    int? favoritesCount,
    int? reviewsCount,
  }) {
    return PatientProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      healthId: healthId ?? this.healthId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      photoBase64: photoBase64 ?? this.photoBase64,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      memberSince: memberSince ?? this.memberSince,
      loyaltyCredits: loyaltyCredits ?? this.loyaltyCredits,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      bp: bp ?? this.bp,
      sugar: sugar ?? this.sugar,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
      allergies: allergies ?? this.allergies,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insurancePolicyNo: insurancePolicyNo ?? this.insurancePolicyNo,
      insuranceValidTill: insuranceValidTill ?? this.insuranceValidTill,
      insuranceCoverage: insuranceCoverage ?? this.insuranceCoverage,
      darkMode: darkMode ?? this.darkMode,
      visitsCount: visitsCount ?? this.visitsCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        initials,
        email,
        phone,
        healthId,
        bloodGroup,
        photoBase64,
        dob,
        age,
        gender,
        memberSince,
        loyaltyCredits,
        emergencyContactName,
        emergencyContactRelation,
        emergencyContactPhone,
        bp,
        sugar,
        weight,
        height,
        bmi,
        allergies,
        insuranceProvider,
        insurancePolicyNo,
        insuranceValidTill,
        insuranceCoverage,
        darkMode,
        visitsCount,
        favoritesCount,
        reviewsCount,
      ];
}
