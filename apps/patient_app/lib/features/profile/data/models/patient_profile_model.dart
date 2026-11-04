import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/patient_profile_entity.dart';

class PatientProfileModel extends PatientProfileEntity {
  const PatientProfileModel({
    required super.id,
    required super.name,
    required super.initials,
    required super.email,
    required super.phone,
    required super.healthId,
    super.bloodGroup,
    super.photoBase64,
    required super.dob,
    super.age,
    super.gender,
    required super.memberSince,
    required super.loyaltyCredits,
    required super.emergencyContactName,
    required super.emergencyContactRelation,
    required super.emergencyContactPhone,
    required super.bp,
    required super.sugar,
    required super.weight,
    required super.height,
    required super.bmi,
    required super.allergies,
    required super.insuranceProvider,
    required super.insurancePolicyNo,
    required super.insuranceValidTill,
    required super.insuranceCoverage,
    super.darkMode,
    super.visitsCount,
    super.favoritesCount,
    super.reviewsCount,
  });

  factory PatientProfileModel.defaultProfile({
    String? id,
    String? name,
    String? email,
    String? phone,
  }) {
    final finalName = name ?? 'Aisha Rahman';
    String initials = 'AR';
    final parts = finalName.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isNotEmpty) {
      if (parts.length > 1) {
        initials = '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
      } else {
        initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    return PatientProfileModel(
      id: id ?? 'user-1',
      name: finalName,
      initials: initials,
      email: email ?? 'aisha.rahman@email.com',
      phone: phone ?? '+91 98765 43210',
      healthId: 'QF-IND-88219',
      bloodGroup: null,
      dob: '14 Aug 1994',
      age: null,
      gender: null,
      memberSince: 'Jan 2026',
      loyaltyCredits: 450,
      emergencyContactName: 'Farhan Rahman',
      emergencyContactRelation: 'Spouse',
      emergencyContactPhone: '+91 98470 11223',
      bp: '120/80 mmHg',
      sugar: '95 mg/dL',
      weight: '62 kg',
      height: '165 cm',
      bmi: '22.8 Normal',
      allergies: const ['Penicillin', 'Dust Mites', 'Peanuts'],
      insuranceProvider: 'Star Health Premier',
      insurancePolicyNo: 'SH-901824901',
      insuranceValidTill: '31 Mar 2027',
      insuranceCoverage: '₹10,00,000',
      darkMode: false,
      visitsCount: 0,
      favoritesCount: 0,
      reviewsCount: 2,
    );
  }

  factory PatientProfileModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    final emergency = json['emergencyContact'] as Map<String, dynamic>? ?? {};
    final vitals = json['vitals'] as Map<String, dynamic>? ?? {};
    final insurance = json['insurance'] as Map<String, dynamic>? ?? {};
    final preferences = json['preferences'] as Map<String, dynamic>? ?? {};

    return PatientProfileModel(
      id: docId ?? json['id'] as String? ?? 'user-1',
      name: json['name'] as String? ?? json['fullName'] as String? ?? 'Aisha Rahman',
      initials: json['initials'] as String? ?? 'AR',
      email: json['email'] as String? ?? 'aisha.rahman@email.com',
      phone: json['phone'] as String? ?? json['phoneNumber'] as String? ?? '+91 98765 43210',
      healthId: json['healthId'] as String? ?? 'QF-IND-88219',
      bloodGroup: json['bloodGroup'] as String?,
      photoBase64: json['photoBase64'] as String?,
      dob: json['dob'] as String? ?? '14 Aug 1994',
      age: json['age'] is int ? json['age'] as int : int.tryParse(json['age']?.toString() ?? ''),
      gender: json['gender'] as String?,
      memberSince: json['memberSince'] as String? ?? 'Jan 2026',
      loyaltyCredits: json['loyaltyCredits'] as int? ?? 450,
      emergencyContactName: emergency['name'] as String? ?? json['emergencyContactName'] as String? ?? 'Farhan Rahman',
      emergencyContactRelation: emergency['relation'] as String? ?? json['emergencyContactRelation'] as String? ?? 'Spouse',
      emergencyContactPhone: emergency['phone'] as String? ?? json['emergencyContactPhone'] as String? ?? '+91 98470 11223',
      bp: vitals['bp'] as String? ?? json['bp'] as String? ?? '120/80 mmHg',
      sugar: vitals['sugar'] as String? ?? json['sugar'] as String? ?? '95 mg/dL',
      weight: vitals['weight'] as String? ?? json['weight'] as String? ?? '62 kg',
      height: vitals['height'] as String? ?? json['height'] as String? ?? '165 cm',
      bmi: vitals['bmi'] as String? ?? json['bmi'] as String? ?? '22.8 Normal',
      allergies: (json['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Penicillin', 'Dust Mites', 'Peanuts'],
      insuranceProvider: insurance['provider'] as String? ?? json['insuranceProvider'] as String? ?? 'Star Health Premier',
      insurancePolicyNo: insurance['policyNo'] as String? ?? json['insurancePolicyNo'] as String? ?? 'SH-901824901',
      insuranceValidTill: insurance['validTill'] as String? ?? json['insuranceValidTill'] as String? ?? '31 Mar 2027',
      insuranceCoverage: insurance['coverage'] as String? ?? json['insuranceCoverage'] as String? ?? '₹10,00,000',
      darkMode: preferences['darkMode'] as bool? ?? json['darkMode'] as bool? ?? false,
      visitsCount: json['visitsCount'] as int? ?? 0,
      favoritesCount: json['favoritesCount'] as int? ?? 0,
      reviewsCount: json['reviewsCount'] as int? ?? 2,
    );
  }

  factory PatientProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return PatientProfileModel.fromJson(data, docId: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initials': initials,
      'email': email,
      'phone': phone,
      'healthId': healthId,
      'bloodGroup': bloodGroup,
      'photoBase64': photoBase64,
      'dob': dob,
      'age': age,
      'gender': gender,
      'memberSince': memberSince,
      'loyaltyCredits': loyaltyCredits,
      'emergencyContact': {
        'name': emergencyContactName,
        'relation': emergencyContactRelation,
        'phone': emergencyContactPhone,
      },
      'vitals': {
        'bp': bp,
        'sugar': sugar,
        'weight': weight,
        'height': height,
        'bmi': bmi,
      },
      'allergies': allergies,
      'insurance': {
        'provider': insuranceProvider,
        'policyNo': insurancePolicyNo,
        'validTill': insuranceValidTill,
        'coverage': insuranceCoverage,
      },
      'preferences': {
        'darkMode': darkMode,
      },
      'visitsCount': visitsCount,
      'favoritesCount': favoritesCount,
      'reviewsCount': reviewsCount,
    };
  }
}
