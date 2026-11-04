import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/favorite_clinic_entity.dart';
import '../../domain/entities/patient_profile_entity.dart';
import '../../domain/entities/patient_review_entity.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/favorite_clinic_model.dart';
import '../models/patient_profile_model.dart';
import '../models/patient_review_model.dart';
import '../models/support_ticket_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  // In-memory cache for snappy reactivity and offline resilience
  PatientProfileModel? _cachedProfile;
  List<PatientReviewModel>? _cachedReviews;
  List<SupportTicketModel>? _cachedTickets;
  List<FavoriteClinicModel>? _cachedFavorites;

  ProfileRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? _safeFirestore(),
        _auth = auth ?? _safeAuth();

  static FirebaseFirestore? _safeFirestore() {
    try {
      if (Firebase.apps.isNotEmpty) return FirebaseFirestore.instance;
    } catch (_) {}
    return null;
  }

  static FirebaseAuth? _safeAuth() {
    try {
      if (Firebase.apps.isNotEmpty) return FirebaseAuth.instance;
    } catch (_) {}
    return null;
  }

  @override
  Future<PatientProfileEntity> getProfile() async {
    if (_cachedProfile != null) {
      return _cachedProfile!;
    }

    final user = _auth?.currentUser;
    String name = 'Aisha Rahman';
    String email = 'aisha.rahman@email.com';
    String phone = '+91 98765 43210';
    String id = user?.uid ?? 'user-1';

    if (user != null) {
      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        name = user.displayName!.trim();
      }
      if (user.email != null && user.email!.isNotEmpty) {
        email = user.email!;
      }
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        phone = user.phoneNumber!;
      }

      if (_firestore != null) {
        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists) {
            final profile = PatientProfileModel.fromFirestore(doc);
            _cachedProfile = profile;
            return profile;
          }
        } catch (e) {
          debugPrint('Error fetching user profile from Firestore: $e');
        }
      }
    }

    final defaultProfile = PatientProfileModel.defaultProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
    );
    _cachedProfile = defaultProfile;
    return defaultProfile;
  }

  @override
  Future<PatientProfileEntity> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String initials,
    int? age,
    String? gender,
    String? bloodGroup,
    String? photoBase64,
  }) async {
    final current = await getProfile();
    final updated = (current as PatientProfileModel).copyWith(
      name: name,
      email: email,
      phone: phone,
      initials: initials,
    );

    final model = PatientProfileModel(
      id: updated.id,
      name: updated.name,
      initials: updated.initials,
      email: updated.email,
      phone: updated.phone,
      healthId: updated.healthId,
      bloodGroup: bloodGroup ?? updated.bloodGroup,
      photoBase64: photoBase64,
      dob: updated.dob,
      age: age,
      gender: gender,
      memberSince: updated.memberSince,
      loyaltyCredits: updated.loyaltyCredits,
      emergencyContactName: updated.emergencyContactName,
      emergencyContactRelation: updated.emergencyContactRelation,
      emergencyContactPhone: updated.emergencyContactPhone,
      bp: updated.bp,
      sugar: updated.sugar,
      weight: updated.weight,
      height: updated.height,
      bmi: updated.bmi,
      allergies: updated.allergies,
      insuranceProvider: updated.insuranceProvider,
      insurancePolicyNo: updated.insurancePolicyNo,
      insuranceValidTill: updated.insuranceValidTill,
      insuranceCoverage: updated.insuranceCoverage,
      darkMode: updated.darkMode,
      visitsCount: updated.visitsCount,
      favoritesCount: updated.favoritesCount,
      reviewsCount: updated.reviewsCount,
    );

    _cachedProfile = model;

    final user = _auth?.currentUser;
    if (user != null && _firestore != null) {
      try {
        await user.updateDisplayName(name);
        await _firestore.collection('users').doc(user.uid).set(
              model.toJson(),
              SetOptions(merge: true),
            );
      } catch (e) {
        debugPrint('Error updating profile in Firestore: $e');
      }
    }

    return model;
  }

  @override
  Future<PatientProfileEntity> toggleDarkMode(bool enabled) async {
    final current = await getProfile();
    final model = PatientProfileModel(
      id: current.id,
      name: current.name,
      initials: current.initials,
      email: current.email,
      phone: current.phone,
      healthId: current.healthId,
      bloodGroup: current.bloodGroup,
      photoBase64: current.photoBase64,
      dob: current.dob,
      age: current.age,
      gender: current.gender,
      memberSince: current.memberSince,
      loyaltyCredits: current.loyaltyCredits,
      emergencyContactName: current.emergencyContactName,
      emergencyContactRelation: current.emergencyContactRelation,
      emergencyContactPhone: current.emergencyContactPhone,
      bp: current.bp,
      sugar: current.sugar,
      weight: current.weight,
      height: current.height,
      bmi: current.bmi,
      allergies: current.allergies,
      insuranceProvider: current.insuranceProvider,
      insurancePolicyNo: current.insurancePolicyNo,
      insuranceValidTill: current.insuranceValidTill,
      insuranceCoverage: current.insuranceCoverage,
      darkMode: enabled,
      visitsCount: current.visitsCount,
      favoritesCount: current.favoritesCount,
      reviewsCount: current.reviewsCount,
    );

    _cachedProfile = model;
    return model;
  }

  @override
  Future<List<FavoriteClinicEntity>> getFavoriteClinics() async {
    if (_cachedFavorites != null) {
      return _cachedFavorites!;
    }
    _cachedFavorites = List.from(FavoriteClinicModel.defaultFavorites);
    return _cachedFavorites!;
  }

  @override
  Future<List<PatientReviewEntity>> getUserReviews() async {
    if (_cachedReviews != null) {
      return _cachedReviews!;
    }
    _cachedReviews = List.from(PatientReviewModel.defaultReviews);
    return _cachedReviews!;
  }

  @override
  Future<PatientReviewEntity> addReview({
    required String clinicId,
    required String clinicName,
    required String doctorName,
    required int rating,
    required List<String> tags,
    required String comment,
    required bool isAnonymous,
  }) async {
    final newReview = PatientReviewModel(
      id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
      clinicId: clinicId,
      clinicName: clinicName,
      doctorName: doctorName.isEmpty ? 'Attending Specialist' : doctorName,
      rating: rating,
      tags: tags,
      comment: comment,
      isAnonymous: isAnonymous,
      date: 'Just now',
    );

    final currentReviews = await getUserReviews();
    _cachedReviews = [newReview, ...currentReviews.map((r) => r as PatientReviewModel)];

    // Update reviews count on cached profile
    if (_cachedProfile != null) {
      _cachedProfile = PatientProfileModel(
        id: _cachedProfile!.id,
        name: _cachedProfile!.name,
        initials: _cachedProfile!.initials,
        email: _cachedProfile!.email,
        phone: _cachedProfile!.phone,
        healthId: _cachedProfile!.healthId,
        bloodGroup: _cachedProfile!.bloodGroup,
        photoBase64: _cachedProfile!.photoBase64,
        dob: _cachedProfile!.dob,
        age: _cachedProfile!.age,
        gender: _cachedProfile!.gender,
        memberSince: _cachedProfile!.memberSince,
        loyaltyCredits: _cachedProfile!.loyaltyCredits + 50, // bonus loyalty points!
        emergencyContactName: _cachedProfile!.emergencyContactName,
        emergencyContactRelation: _cachedProfile!.emergencyContactRelation,
        emergencyContactPhone: _cachedProfile!.emergencyContactPhone,
        bp: _cachedProfile!.bp,
        sugar: _cachedProfile!.sugar,
        weight: _cachedProfile!.weight,
        height: _cachedProfile!.height,
        bmi: _cachedProfile!.bmi,
        allergies: _cachedProfile!.allergies,
        insuranceProvider: _cachedProfile!.insuranceProvider,
        insurancePolicyNo: _cachedProfile!.insurancePolicyNo,
        insuranceValidTill: _cachedProfile!.insuranceValidTill,
        insuranceCoverage: _cachedProfile!.insuranceCoverage,
        darkMode: _cachedProfile!.darkMode,
        visitsCount: _cachedProfile!.visitsCount,
        favoritesCount: _cachedProfile!.favoritesCount,
        reviewsCount: _cachedReviews!.length,
      );
    }

    if (_firestore != null) {
      try {
        await _firestore.collection('reviews').doc(newReview.id).set(newReview.toJson());
      } catch (e) {
        debugPrint('Firestore review write skipped/failed: $e');
      }
    }

    return newReview;
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    final list = await getUserReviews();
    _cachedReviews = list
        .where((r) => r.id != reviewId)
        .map((r) => r as PatientReviewModel)
        .toList();

    if (_cachedProfile != null) {
      _cachedProfile = PatientProfileModel(
        id: _cachedProfile!.id,
        name: _cachedProfile!.name,
        initials: _cachedProfile!.initials,
        email: _cachedProfile!.email,
        phone: _cachedProfile!.phone,
        healthId: _cachedProfile!.healthId,
        bloodGroup: _cachedProfile!.bloodGroup,
        photoBase64: _cachedProfile!.photoBase64,
        dob: _cachedProfile!.dob,
        age: _cachedProfile!.age,
        gender: _cachedProfile!.gender,
        memberSince: _cachedProfile!.memberSince,
        loyaltyCredits: _cachedProfile!.loyaltyCredits,
        emergencyContactName: _cachedProfile!.emergencyContactName,
        emergencyContactRelation: _cachedProfile!.emergencyContactRelation,
        emergencyContactPhone: _cachedProfile!.emergencyContactPhone,
        bp: _cachedProfile!.bp,
        sugar: _cachedProfile!.sugar,
        weight: _cachedProfile!.weight,
        height: _cachedProfile!.height,
        bmi: _cachedProfile!.bmi,
        allergies: _cachedProfile!.allergies,
        insuranceProvider: _cachedProfile!.insuranceProvider,
        insurancePolicyNo: _cachedProfile!.insurancePolicyNo,
        insuranceValidTill: _cachedProfile!.insuranceValidTill,
        insuranceCoverage: _cachedProfile!.insuranceCoverage,
        darkMode: _cachedProfile!.darkMode,
        visitsCount: _cachedProfile!.visitsCount,
        favoritesCount: _cachedProfile!.favoritesCount,
        reviewsCount: _cachedReviews!.length,
      );
    }
  }

  @override
  Future<List<SupportTicketEntity>> getSupportTickets() async {
    if (_cachedTickets != null) {
      return _cachedTickets!;
    }
    _cachedTickets = List.from(SupportTicketModel.defaultTickets);
    return _cachedTickets!;
  }

  @override
  Future<SupportTicketEntity> createSupportTicket({
    required String clinicId,
    required String clinicName,
    required String category,
    required String subject,
    required String description,
  }) async {
    final ticketNum = (DateTime.now().millisecondsSinceEpoch % 900) + 100;
    final newId = 'TKT-$ticketNum';
    final profile = await getProfile();

    final newTicket = SupportTicketModel(
      id: newId,
      clinicId: clinicId,
      clinicName: clinicName,
      category: category,
      subject: subject,
      description: description,
      status: 'open',
      priority: category == 'queue' ? 'high' : 'medium',
      createdAt: 'Just now',
      slaNotice: 'Est. SLA: Resolution within 2 hrs',
      messages: [
        TicketMessageModel(
          sender: profile.name,
          text: description.isNotEmpty ? description : subject,
          time: 'Just now',
          isUser: true,
        ),
      ],
    );

    final tickets = await getSupportTickets();
    _cachedTickets = [newTicket, ...tickets.map((t) => t as SupportTicketModel)];
    return newTicket;
  }

  @override
  Future<SupportTicketEntity> sendTicketReply({
    required String ticketId,
    required String text,
    required String senderName,
  }) async {
    final tickets = await getSupportTickets();
    final idx = tickets.indexWhere((t) => t.id == ticketId);
    if (idx == -1) {
      throw Exception('Ticket not found');
    }

    final ticket = tickets[idx] as SupportTicketModel;
    final updatedMessages = [
      ...ticket.messages,
      TicketMessageModel(
        sender: senderName,
        text: text,
        time: 'Just now',
        isUser: true,
      ),
      // Auto clinic desk acknowledgement simulation
      const TicketMessageModel(
        sender: 'Clinic Front Desk (Auto)',
        text: 'Message received. A care coordinator has been notified.',
        time: 'Just now',
        isUser: false,
      ),
    ];

    final updatedTicket = SupportTicketModel(
      id: ticket.id,
      clinicId: ticket.clinicId,
      clinicName: ticket.clinicName,
      category: ticket.category,
      subject: ticket.subject,
      description: ticket.description,
      status: 'in_progress',
      priority: ticket.priority,
      createdAt: ticket.createdAt,
      slaNotice: ticket.slaNotice,
      messages: updatedMessages,
    );

    final updatedList = List<SupportTicketModel>.from(_cachedTickets!);
    updatedList[idx] = updatedTicket;
    _cachedTickets = updatedList;

    return updatedTicket;
  }

  @override
  Future<void> logout() async {
    _cachedProfile = null;
    _cachedReviews = null;
    _cachedTickets = null;
    _cachedFavorites = null;
    try {
      await _auth?.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    _cachedProfile = null;
    _cachedReviews = null;
    _cachedTickets = null;
    _cachedFavorites = null;
    try {
      final user = _auth?.currentUser;
      if (user != null) {
        if (_firestore != null) {
          await _firestore.collection('users').doc(user.uid).delete();
        }
        await user.delete();
      }
    } catch (e) {
      debugPrint('Account delete error: $e');
    }
  }
}
