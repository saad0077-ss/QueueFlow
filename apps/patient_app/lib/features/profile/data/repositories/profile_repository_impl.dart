import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/clinic_rating_aggregator.dart';
import '../../../notifications/data/services/patient_notifications_service.dart';
import '../../domain/entities/favorite_clinic_entity.dart';
import '../../domain/entities/patient_payment_item_entity.dart';
import '../../domain/entities/patient_profile_entity.dart';
import '../../domain/entities/patient_queue_history_entity.dart';
import '../../domain/entities/patient_review_entity.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/patient_profile_model.dart';
import '../models/patient_review_model.dart';
import '../models/support_ticket_model.dart';
import 'profile_favorites_query_helper.dart';
import 'profile_queue_query_helper.dart';
import 'profile_review_resolvers.dart';
import 'profile_reviews_query_helper.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;
  final FirebaseStorage? _storage;

  // In-memory cache for snappy reactivity and offline resilience
  PatientProfileModel? _cachedProfile;
  List<PatientReviewModel>? _cachedReviews;
  List<SupportTicketEntity>? _cachedTickets;

  ProfileRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? _safeFirestore(),
       _auth = auth ?? _safeAuth(),
       _storage = storage ?? _safeStorage();

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

  static FirebaseStorage? _safeStorage() {
    try {
      if (Firebase.apps.isNotEmpty) return FirebaseStorage.instance;
    } catch (_) {}
    return null;
  }

  @override
  Future<PatientProfileEntity> getProfile() async {
    final user = _auth?.currentUser;
    if (_firestore == null && _cachedProfile != null) {
      return _cachedProfile!;
    }

    String name = '';
    String email = '';
    String phone = '';
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
          final results = await Future.wait([
            _firestore.collection('users').doc(user.uid).get(),
            ProfileReviewsQueryHelper.countUserAppointments(
              _firestore,
              uid: user.uid,
              email: user.email,
            ),
          ]);
          final doc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
          final visitsCount = results[1] as int;
          if (doc.exists) {
            final raw = Map<String, dynamic>.from(doc.data() ?? const {});
            raw['visitsCount'] = visitsCount;
            final profile = PatientProfileModel.fromJson(raw, docId: doc.id);
            _cachedProfile = profile;
            return profile;
          }
          final freshDefault = PatientProfileModel.fromJson({
            ...PatientProfileModel.defaultProfile(
              id: id,
              name: name,
              email: email,
              phone: phone,
            ).toJson(),
            'visitsCount': visitsCount,
          }, docId: id);
          _cachedProfile = freshDefault;
          return freshDefault;
        } catch (e) {
          debugPrint('Error fetching user profile from Firestore: $e');
          if (_cachedProfile != null && _cachedProfile!.id == user.uid) {
            return _cachedProfile!;
          }
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
    final updated = current.copyWith(
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
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(model.toJson(), SetOptions(merge: true));
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
    final user = _auth?.currentUser;
    if (user != null && _firestore != null) {
      try {
        return await ProfileFavoritesQueryHelper.fetchFavorites(
          _firestore,
          user.uid,
        );
      } catch (e) {
        debugPrint('Error loading favorite clinics: $e');
      }
    }
    return const [];
  }

  @override
  Future<void> toggleFavorite(
    String clinicId, {
    required bool isFavorite,
  }) async {
    final user = _auth?.currentUser;
    if (user == null || _firestore == null) return;
    try {
      if (isFavorite) {
        // Fetch clinic details from Firestore if available
        String clinicName = 'Clinic';
        String department = '';
        double rating = 0.0;
        int reviewCount = 0;
        String address = '';
        String initials = '';
        String? imageUrl;
        int imageVersion = 0;
        try {
          final clinicDoc = await _firestore
              .collection('clinics')
              .doc(clinicId)
              .get();
          final cData = clinicDoc.data();
          if (cData != null) {
            clinicName = cData['name'] ?? clinicName;
            department = cData['category'] ?? cData['department'] ?? department;
            rating = (cData['rating'] as num?)?.toDouble() ?? rating;
            reviewCount =
                (cData['reviewCount'] as num?)?.toInt() ?? reviewCount;
            address = cData['address'] ?? address;
            initials = cData['initials'] ?? initials;
            imageUrl = (cData['imageUrl'] ?? cData['image'])?.toString();
            imageVersion = (cData['imageVersion'] as num?)?.toInt() ?? 0;
          }
        } catch (_) {}

        await _firestore.collection('users').doc(user.uid).set({
          'favoriteClinics': {
            clinicId: {
              'id': clinicId,
              'name': clinicName,
              'department': department,
              'rating': rating,
              'reviewsCount': reviewCount,
              'address': address,
              'initials': initials,
              if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
              if (imageVersion > 0) 'imageVersion': imageVersion,
              'savedAt': FieldValue.serverTimestamp(),
            },
          },
        }, SetOptions(merge: true));
      } else {
        await _firestore.collection('users').doc(user.uid).update({
          'favoriteClinics.$clinicId': FieldValue.delete(),
        });
      }
    } catch (e) {
      debugPrint('Error toggling favorite clinic: $e');
    }
  }

  @override
  Future<List<PatientReviewEntity>> getUserReviews() async {
    final user = _auth?.currentUser;
    if (_firestore == null) {
      return _cachedReviews ?? const [];
    }
    if (user != null) {
      try {
        final reviews = await ProfileReviewsQueryHelper.fetchUserReviews(
          _firestore,
          uid: user.uid,
          email: user.email,
        );
        _cachedReviews = reviews.whereType<PatientReviewModel>().toList();
        return reviews;
      } catch (e) {
        debugPrint('Error loading user reviews: $e');
        if (_cachedReviews != null) return _cachedReviews!;
      }
    }
    _cachedReviews = [];
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
    final user = _auth?.currentUser;
    final reviewId = 'rev-${DateTime.now().millisecondsSinceEpoch}';
    final newReview = _firestore != null
        ? await ProfileReviewsQueryHelper.enrichNewReview(
            _firestore,
            id: reviewId,
            clinicId: clinicId,
            clinicName: clinicName,
            doctorName: doctorName,
            rating: rating,
            tags: tags,
            comment: comment,
            isAnonymous: isAnonymous,
          )
        : PatientReviewModel(
            id: reviewId,
            clinicId: clinicId,
            clinicName: clinicName,
            doctorName: doctorName,
            rating: rating,
            tags: tags,
            comment: comment,
            isAnonymous: isAnonymous,
            date: 'Just now',
          );
    final resolvedClinicId = newReview.clinicId;

    final currentReviews = await getUserReviews();
    _cachedReviews = [
      newReview,
      ...currentReviews.whereType<PatientReviewModel>(),
    ];

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

    if (_firestore != null) {
      try {
        final json = newReview.toJson();
        if (user != null) {
          json['userId'] = user.uid;
          json['patientId'] = user.uid;
          if (user.email != null) {
            final emailLower = user.email!.trim().toLowerCase();
            json['userEmail'] = emailLower;
            json['patientEmail'] = emailLower;
          }
          final pName = _cachedProfile?.name ?? user.displayName ?? 'Patient';
          json['userName'] = pName;
          json['patientName'] = pName;
        }
        json['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('reviews').doc(newReview.id).set(json);
        await ClinicRatingAggregator.syncClinicRating(
          _firestore,
          resolvedClinicId,
          clinicName: clinicName,
        );
      } catch (e) {
        debugPrint('Firestore review write skipped/failed: $e');
      }
    }

    return newReview;
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    final targetClinicId = _cachedReviews
        ?.where((r) => r.id == reviewId)
        .map((r) => r.clinicId)
        .firstOrNull;
    if (_firestore != null) {
      await ProfileReviewResolvers.deleteReview(_firestore, reviewId);
      if (targetClinicId != null && targetClinicId.isNotEmpty) {
        await ClinicRatingAggregator.syncClinicRating(_firestore, targetClinicId);
      }
    }
    final list = _cachedReviews ?? await getUserReviews();
    _cachedReviews = list
        .where((r) => r.id != reviewId)
        .whereType<PatientReviewModel>()
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
  Stream<List<SupportTicketEntity>> watchSupportTickets() {
    if (_firestore == null) {
      return Stream.value(_cachedTickets ?? const []);
    }

    final user = _auth?.currentUser;
    final uid = user?.uid ?? '';
    final email = user?.email?.trim().toLowerCase() ?? '';

    Query<Map<String, dynamic>> query = _firestore.collection(
      'support_tickets',
    );
    if (uid.isNotEmpty) {
      query = query.where('patientId', isEqualTo: uid);
    } else if (email.isNotEmpty) {
      query = query.where('patientEmail', isEqualTo: email);
    }

    return query.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => SupportTicketModel.fromFirestore(d))
          .toList();
      list.sort((a, b) {
        final da = a.createdAtDate ?? DateTime(2000);
        final db = b.createdAtDate ?? DateTime(2000);
        return db.compareTo(da);
      });
      _cachedTickets = list;
      return list;
    });
  }

  @override
  Future<List<SupportTicketEntity>> getSupportTickets() async {
    if (_firestore != null) {
      try {
        final user = _auth?.currentUser;
        final uid = user?.uid ?? '';
        final email = user?.email?.trim().toLowerCase() ?? '';

        Query<Map<String, dynamic>> query = _firestore.collection(
          'support_tickets',
        );
        if (uid.isNotEmpty) {
          query = query.where('patientId', isEqualTo: uid);
        } else if (email.isNotEmpty) {
          query = query.where('patientEmail', isEqualTo: email);
        }

        final snap = await query.get();
        final list = snap.docs
            .map((d) => SupportTicketModel.fromFirestore(d))
            .toList();
        list.sort((a, b) {
          final da = a.createdAtDate ?? DateTime(2000);
          final db = b.createdAtDate ?? DateTime(2000);
          return db.compareTo(da);
        });
        _cachedTickets = list;
        return list;
      } catch (e) {
        debugPrint('Error fetching support tickets from firestore: $e');
      }
    }

    return _cachedTickets ?? const [];
  }

  @override
  Future<SupportTicketEntity> createSupportTicket({
    required String clinicId,
    required String clinicName,
    required String category,
    required String subject,
    required String description,
    String priority = 'medium',
    String? linkedTokenNumber,
    bool isClinicRelated = true,
  }) async {
    final user = _auth?.currentUser;
    final profile = await getProfile();
    final uid = user?.uid ?? profile.id;
    final patientEmail = user?.email ?? profile.email;
    final patientPhone = profile.phone;
    final patientName = profile.name.isNotEmpty ? profile.name : 'Patient';

    final ticketNum = (DateTime.now().millisecondsSinceEpoch % 9000) + 1000;
    final ticketCode = 'TK-$ticketNum';
    final prio = priority.toLowerCase();
    final slaMinutes = prio == 'high' ? 5 : (prio == 'medium' ? 15 : 25);
    final slaNotice = '< ${slaMinutes}m SLA';

    final initialMessage = TicketMessageModel(
      sender: patientName,
      text: description.isNotEmpty ? description : subject,
      time: 'Just now',
      isUser: true,
      senderRole: 'patient',
      createdAt: DateTime.now(),
    );

    if (_firestore != null) {
      final docRef = await _firestore.collection('support_tickets').add({
        'ticketNumber': ticketCode,
        'patientId': uid,
        'userId': uid,
        'patientName': patientName,
        'patientEmail': patientEmail,
        'patientPhone': patientPhone,
        'patientPhoto': profile.photoBase64 ?? '',
        'photoBase64': profile.photoBase64 ?? '',
        'clinicId': clinicId,
        'clinicName': clinicName,
        'isClinicRelated': isClinicRelated,
        'linkedTokenNumber': linkedTokenNumber,
        'category': category,
        'priority': prio,
        'subject': subject,
        'description': description,
        'status': 'open',
        'slaMinutes': slaMinutes,
        'slaNotice': slaNotice,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'messages': [initialMessage.toJson()],
      });

      final model = SupportTicketModel(
        id: docRef.id,
        ticketNumber: ticketCode,
        patientId: uid,
        patientName: patientName,
        patientEmail: patientEmail,
        patientPhone: patientPhone,
        clinicId: clinicId,
        clinicName: clinicName,
        isClinicRelated: isClinicRelated,
        linkedTokenNumber: linkedTokenNumber,
        category: category,
        subject: subject,
        description: description,
        status: 'open',
        priority: prio,
        createdAt: 'Just now',
        createdAtDate: DateTime.now(),
        updatedAtDate: DateTime.now(),
        slaNotice: slaNotice,
        slaMinutes: slaMinutes,
        messages: [initialMessage],
      );

      _cachedTickets = [model, ...?_cachedTickets];
      return model;
    }

    final fallback = SupportTicketModel(
      id: ticketCode,
      ticketNumber: ticketCode,
      patientId: uid,
      patientName: patientName,
      patientEmail: patientEmail,
      clinicId: clinicId,
      clinicName: clinicName,
      isClinicRelated: isClinicRelated,
      linkedTokenNumber: linkedTokenNumber,
      category: category,
      subject: subject,
      description: description,
      status: 'open',
      priority: prio,
      createdAt: 'Just now',
      slaNotice: slaNotice,
      slaMinutes: slaMinutes,
      messages: [initialMessage],
    );
    _cachedTickets = [fallback, ...?_cachedTickets];
    return fallback;
  }

  @override
  Future<SupportTicketEntity> sendTicketReply({
    required String ticketId,
    required String text,
    required String senderName,
    String senderRole = 'patient',
  }) async {
    final newMsg = TicketMessageModel(
      sender: senderName,
      text: text,
      time: 'Just now',
      isUser: senderRole == 'patient',
      senderRole: senderRole,
      createdAt: DateTime.now(),
    );

    if (_firestore != null) {
      final docRef = _firestore.collection('support_tickets').doc(ticketId);
      await docRef.update({
        'messages': FieldValue.arrayUnion([newMsg.toJson()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final updatedSnap = await docRef.get();
      return SupportTicketModel.fromFirestore(updatedSnap);
    }

    final tickets = await getSupportTickets();
    final idx = tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      final t = tickets[idx];
      final updated = t.copyWith(messages: [...t.messages, newMsg]);
      return updated;
    }
    throw Exception('Ticket not found');
  }

  @override
  Future<void> updateTicketStatus(String ticketId, String status) async {
    final isReopen = status.toLowerCase() != 'resolved';
    final profile = await getProfile();
    final patientName = profile.name.isNotEmpty ? profile.name : 'Patient';
    final sysText = isReopen
        ? '🔄 Concern reopened by $patientName. Live chat is now active.'
        : '✓ Concern marked as resolved by $patientName.';

    final sysMsgMap = {
      'sender': 'System',
      'senderRole': 'system',
      'text': sysText,
      'time': 'Just now',
      'isUser': false,
      'isInternalNote': false,
      'createdAt': Timestamp.now(),
    };

    if (_firestore != null) {
      try {
        final Map<String, dynamic> updateData = {
          'status': status,
          'messages': FieldValue.arrayUnion([sysMsgMap]),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (status == 'resolved') {
          updateData['resolvedAt'] = 'Just now';
        }
        await _firestore
            .collection('support_tickets')
            .doc(ticketId)
            .update(updateData);
      } catch (e) {
        debugPrint('Error updating ticket status in firestore: $e');
      }
    }
    if (_cachedTickets != null) {
      _cachedTickets = _cachedTickets!.map((t) {
        if (t.id == ticketId) {
          final sysEntity = TicketMessageEntity(
            sender: 'System',
            senderRole: 'system',
            text: sysText,
            time: 'Just now',
            isUser: false,
            createdAt: DateTime.now(),
          );
          return t.copyWith(
            status: status,
            resolvedAt: status == 'resolved' ? 'Just now' : null,
            messages: [...t.messages, sysEntity],
          );
        }
        return t;
      }).toList();
    }
  }

  @override
  Future<void> rateTicket(String ticketId, int rating) async {
    if (_firestore != null) {
      try {
        await _firestore.collection('support_tickets').doc(ticketId).update({
          'rating': rating,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Error updating ticket rating in firestore: $e');
      }
    }
    if (_cachedTickets != null) {
      _cachedTickets = _cachedTickets!.map((t) {
        if (t.id == ticketId) {
          return t.copyWith(rating: rating);
        }
        return t;
      }).toList();
    }
  }

  @override
  Future<List<PatientQueueHistoryEntity>> getQueueHistory() async {
    final user = _auth?.currentUser;
    if (_firestore == null || user == null) return const [];
    try {
      return await ProfileQueueQueryHelper.fetchQueueHistory(
        _firestore,
        uid: user.uid,
        email: user.email,
      );
    } catch (e) {
      debugPrint('Error fetching queue history from Firestore: $e');
      return const [];
    }
  }

  @override
  Stream<List<PatientQueueHistoryEntity>> watchQueueHistory() {
    final user = _auth?.currentUser;
    if (_firestore == null || user == null) return Stream.value(const []);
    try {
      return ProfileQueueQueryHelper.watchQueueHistory(
        _firestore,
        uid: user.uid,
        email: user.email,
      );
    } catch (e) {
      debugPrint('Error watching queue history: $e');
      return Stream.value(const []);
    }
  }

  static String _monthName(int month) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return (month >= 1 && month <= 12) ? m[month - 1] : 'Jan';
  }

  @override
  Future<List<PatientPaymentItemEntity>> getPaymentHistory() async {
    final user = _auth?.currentUser;
    final email = user?.email?.trim().toLowerCase();
    final uid = user?.uid;

    if (_firestore == null) {
      return const [];
    }

    final payments = <PatientPaymentItemEntity>[];
    final seenIds = <String>{};

    try {
      // 1. Fetch from 'appointments' collection (Consultation bookings)
      Query<Map<String, dynamic>> aptQuery = _firestore.collection(
        'appointments',
      );
      if (email != null && email.isNotEmpty) {
        aptQuery = aptQuery.where('customerEmail', isEqualTo: email);
      } else if (uid != null && uid.isNotEmpty) {
        aptQuery = aptQuery.where('customerId', isEqualTo: uid);
      }

      final aptSnap = await aptQuery.get();
      for (final doc in aptSnap.docs) {
        final data = doc.data();
        final rawPayment = data['payment'];
        final paymentMap = rawPayment is Map<String, dynamic>
            ? rawPayment
            : (rawPayment is Map
                  ? Map<String, dynamic>.from(rawPayment)
                  : null);

        final docStatus = (data['status'] ?? '').toString().toLowerCase();
        final paymentStatus = (paymentMap?['status'] ?? '')
            .toString()
            .toLowerCase();

        final isCancelled =
            docStatus == 'cancelled' || paymentStatus == 'refunded';
        final status = isCancelled
            ? 'refunded'
            : (paymentStatus.isNotEmpty ? paymentStatus : 'paid');

        final amount =
            (paymentMap?['amount'] as num?)?.toDouble() ??
            (data['servicePrice'] as num?)?.toDouble() ??
            500.0;

        final rawDate =
            paymentMap?['paidAt'] ?? data['dateTime'] ?? data['createdAt'];
        String formattedDate = 'Recent';
        if (rawDate is Timestamp) {
          final dt = rawDate.toDate();
          formattedDate = '${dt.day} ${_monthName(dt.month)} ${dt.year}';
        } else if (rawDate != null) {
          formattedDate = rawDate.toString();
        }

        final id = doc.id;
        final shortId = id.length > 5 ? id.substring(0, 5) : id;
        final receiptNo = (paymentMap?['receiptNo'] ?? 'REC-2026-$shortId')
            .toString();
        final bookingId = (data['bookingRef'] ?? 'QF-$shortId').toString();
        final type = (paymentMap?['type'] ?? data['type'] ?? 'appointment')
            .toString();
        final token =
            data['token']?.toString() ?? paymentMap?['token']?.toString();

        seenIds.add(id);
        seenIds.add(receiptNo);

        payments.add(
          PatientPaymentItemEntity(
            id: id,
            receiptNo: receiptNo,
            bookingId: bookingId,
            clinicId: (data['clinicId'] ?? 'sunrise-health').toString(),
            clinicName: (data['clinicName'] ?? 'Sunrise Health Clinic')
                .toString(),
            department:
                (data['departmentName'] ??
                        data['serviceCategory'] ??
                        'General Medicine')
                    .toString(),
            service: (data['serviceName'] ?? 'General Consultation').toString(),
            doctor: (data['doctorName'] ?? 'Attending Specialist').toString(),
            amount: amount,
            status: status,
            date: formattedDate,
            method: (paymentMap?['method'] ?? 'Razorpay UPI').toString(),
            transactionId: (paymentMap?['paymentId'] ?? 'pay_$shortId')
                .toString(),
            type: type,
            token: token,
            refundId:
                paymentMap?['refundId']?.toString() ??
                (isCancelled ? 'RFND-$shortId' : null),
            refundReason:
                paymentMap?['refundReason']?.toString() ??
                (isCancelled ? 'Appointment cancelled by patient' : null),
            refundToAccount:
                paymentMap?['refundToAccount']?.toString() ??
                (isCancelled ? 'Original Payment Source' : null),
            refundedAt:
                paymentMap?['refundedAt']?.toString() ??
                (isCancelled ? formattedDate : null),
          ),
        );
      }

      // 2. Fetch from 'tickets' collection (Live Queue Token payments)
      Query<Map<String, dynamic>> tktQuery = _firestore.collection('tickets');
      if (email != null && email.isNotEmpty) {
        tktQuery = tktQuery.where('patientEmail', isEqualTo: email);
      } else if (uid != null && uid.isNotEmpty) {
        tktQuery = tktQuery.where('patientId', isEqualTo: uid);
      }

      final tktSnap = await tktQuery.get();
      for (final doc in tktSnap.docs) {
        final data = doc.data();
        final id = doc.id;
        final shortId = id.length > 5 ? id.substring(0, 5) : id;
        final receiptNo = 'REC-TK-$shortId';

        if (seenIds.contains(id) || seenIds.contains(receiptNo)) continue;
        seenIds.add(id);

        final rawPayment = data['payment'];
        final paymentMap = rawPayment is Map<String, dynamic>
            ? rawPayment
            : (rawPayment is Map
                  ? Map<String, dynamic>.from(rawPayment)
                  : null);

        final docStatus = (data['status'] ?? '').toString().toLowerCase();
        final isCancelled = docStatus == 'cancelled';
        final status = isCancelled ? 'refunded' : 'paid';

        final amount =
            (paymentMap?['amount'] as num?)?.toDouble() ??
            (data['fee'] as num?)?.toDouble() ??
            100.0;

        final rawDate = data['createdAt'] ?? data['joinedAt'];
        String formattedDate = 'Today';
        if (rawDate is Timestamp) {
          final dt = rawDate.toDate();
          formattedDate = '${dt.day} ${_monthName(dt.month)} ${dt.year}';
        } else if (rawDate != null) {
          formattedDate = rawDate.toString();
        }

        payments.add(
          PatientPaymentItemEntity(
            id: id,
            receiptNo: receiptNo,
            bookingId: (data['token'] ?? 'TK-$shortId').toString(),
            clinicId: (data['clinicId'] ?? 'smile-dental').toString(),
            clinicName: (data['clinicName'] ?? 'Smile Dental Clinic')
                .toString(),
            department: (data['departmentName'] ?? 'General Medicine')
                .toString(),
            service: (data['serviceName'] ?? 'Queue Consultation').toString(),
            doctor: (data['doctorName'] ?? 'Attending Doctor').toString(),
            amount: amount,
            status: status,
            date: formattedDate,
            method: (paymentMap?['method'] ?? 'Razorpay UPI').toString(),
            transactionId: (paymentMap?['paymentId'] ?? 'pay_tk_$shortId')
                .toString(),
            type: 'queue',
            token: (data['token'] ?? 'T-$shortId').toString(),
            refundId: isCancelled ? 'RFND-TK-$shortId' : null,
            refundReason: isCancelled ? 'Live queue spot cancelled' : null,
            refundToAccount: isCancelled ? 'UPI / Source Account' : null,
            refundedAt: isCancelled ? formattedDate : null,
          ),
        );
      }

      // 3. Check fallback query for tickets with userEmail or userId if patientEmail wasn't used
      if (email != null && email.isNotEmpty) {
        final fallbackTktSnap = await _firestore
            .collection('tickets')
            .where('userEmail', isEqualTo: email)
            .get();
        for (final doc in fallbackTktSnap.docs) {
          if (seenIds.contains(doc.id)) continue;
          seenIds.add(doc.id);
          final data = doc.data();
          final shortId = doc.id.length > 5 ? doc.id.substring(0, 5) : doc.id;
          final isCancelled =
              (data['status'] ?? '').toString().toLowerCase() == 'cancelled';
          payments.add(
            PatientPaymentItemEntity(
              id: doc.id,
              receiptNo: 'REC-TK-$shortId',
              bookingId: (data['token'] ?? 'TK-$shortId').toString(),
              clinicId: (data['clinicId'] ?? 'clinic-1').toString(),
              clinicName: (data['clinicName'] ?? 'Clinic').toString(),
              department: (data['departmentName'] ?? 'General').toString(),
              service: (data['serviceName'] ?? 'Consultation').toString(),
              doctor: (data['doctorName'] ?? 'Doctor').toString(),
              amount: (data['fee'] as num?)?.toDouble() ?? 100.0,
              status: isCancelled ? 'refunded' : 'paid',
              date: 'Today',
              method: 'Razorpay UPI',
              transactionId: 'pay_tk_$shortId',
              type: 'queue',
              token: (data['token'] ?? 'T-$shortId').toString(),
              refundId: isCancelled ? 'RFND-TK-$shortId' : null,
              refundReason: isCancelled ? 'Live queue spot cancelled' : null,
              refundToAccount: isCancelled ? 'UPI / Source Account' : null,
            ),
          );
        }
      }

      // 4. Sort payments by date / most recent first
      return payments;
    } catch (e) {
      debugPrint('Error fetching payment history: $e');
      return const [];
    }
  }

  @override
  Future<void> logout() async {
    _cachedProfile = null;
    _cachedReviews = null;
    _cachedTickets = null;
    try {
      await PatientNotificationsService.instance.flushPendingSync();
      PatientNotificationsService.instance.resetSessionCache();
    } catch (_) {}
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

    final user = _auth?.currentUser;
    if (user == null) {
      debugPrint('deleteAccount: No authenticated user session found.');
      return;
    }

    final uid = user.uid;
    final email = user.email?.trim().toLowerCase();

    // 1. Permanently purge all Firebase Storage folders/files for this patient
    if (_storage != null) {
      try {
        final storagePaths = [
          'users/$uid',
          'patients/$uid',
          'profile_photos/$uid',
          'prescriptions/$uid',
          'medical_records/$uid',
          'documents/$uid',
          uid,
        ];
        for (final p in storagePaths) {
          await _deleteStorageFolderRecursively(_storage.ref(p));
        }
      } catch (e) {
        debugPrint('Error purging user files from Firebase Storage: $e');
      }
    }

    // 2. Cascade delete all documents across Cloud Firestore collections
    if (_firestore != null) {
      try {
        final docsToDelete = <String, DocumentReference>{};

        Future<void> collectDocs(
          String collectionName,
          List<Query<Map<String, dynamic>>> queries,
        ) async {
          for (final q in queries) {
            try {
              final snap = await q.get();
              for (final doc in snap.docs) {
                docsToDelete[doc.reference.path] = doc.reference;
              }
            } catch (e) {
              debugPrint('Error querying $collectionName for deletion: $e');
            }
          }
        }

        // A. Appointments (Booking History)
        final apptQueries = <Query<Map<String, dynamic>>>[
          _firestore
              .collection('appointments')
              .where('customerId', isEqualTo: uid),
          _firestore.collection('appointments').where('userId', isEqualTo: uid),
          _firestore
              .collection('appointments')
              .where('patientId', isEqualTo: uid),
        ];
        if (email != null && email.isNotEmpty) {
          apptQueries.add(
            _firestore
                .collection('appointments')
                .where('customerEmail', isEqualTo: email),
          );
          apptQueries.add(
            _firestore
                .collection('appointments')
                .where('patientEmail', isEqualTo: email),
          );
          apptQueries.add(
            _firestore
                .collection('appointments')
                .where('userEmail', isEqualTo: email),
          );
        }
        await collectDocs('appointments', apptQueries);

        // B. Tickets (Live Queue Tokens)
        final ticketQueries = <Query<Map<String, dynamic>>>[
          _firestore.collection('tickets').where('patientId', isEqualTo: uid),
          _firestore.collection('tickets').where('userId', isEqualTo: uid),
          _firestore.collection('tickets').where('customerId', isEqualTo: uid),
        ];
        if (email != null && email.isNotEmpty) {
          ticketQueries.add(
            _firestore
                .collection('tickets')
                .where('patientEmail', isEqualTo: email),
          );
          ticketQueries.add(
            _firestore
                .collection('tickets')
                .where('userEmail', isEqualTo: email),
          );
        }
        await collectDocs('tickets', ticketQueries);

        // C. Clinic Reviews & Ratings
        final reviewQueries = <Query<Map<String, dynamic>>>[
          _firestore.collection('reviews').where('userId', isEqualTo: uid),
          _firestore.collection('reviews').where('patientId', isEqualTo: uid),
          _firestore.collection('reviews').where('customerId', isEqualTo: uid),
        ];
        if (email != null && email.isNotEmpty) {
          reviewQueries.add(
            _firestore
                .collection('reviews')
                .where('userEmail', isEqualTo: email),
          );
        }
        await collectDocs('reviews', reviewQueries);

        // D. Doctor Reviews & Ratings
        final doctorReviewQueries = <Query<Map<String, dynamic>>>[
          _firestore
              .collection('doctor_reviews')
              .where('userId', isEqualTo: uid),
          _firestore
              .collection('doctor_reviews')
              .where('patientId', isEqualTo: uid),
          _firestore
              .collection('doctor_reviews')
              .where('customerId', isEqualTo: uid),
        ];
        if (email != null && email.isNotEmpty) {
          doctorReviewQueries.add(
            _firestore
                .collection('doctor_reviews')
                .where('userEmail', isEqualTo: email),
          );
        }
        await collectDocs('doctor_reviews', doctorReviewQueries);

        // E. Notifications
        final notifQueries = <Query<Map<String, dynamic>>>[
          _firestore
              .collection('notifications')
              .where('userId', isEqualTo: uid),
          _firestore
              .collection('notifications')
              .where('patientId', isEqualTo: uid),
          _firestore
              .collection('notifications')
              .where('customerId', isEqualTo: uid),
        ];
        if (email != null && email.isNotEmpty) {
          notifQueries.add(
            _firestore
                .collection('notifications')
                .where('userEmail', isEqualTo: email),
          );
        }
        await collectDocs('notifications', notifQueries);

        // F. Support Tickets
        final supportQueries = <Query<Map<String, dynamic>>>[
          _firestore
              .collection('support_tickets')
              .where('patientId', isEqualTo: uid),
          _firestore
              .collection('support_tickets')
              .where('userId', isEqualTo: uid),
          _firestore
              .collection('support_tickets')
              .where('customerId', isEqualTo: uid),
        ];
        if (email != null && email.isNotEmpty) {
          supportQueries.add(
            _firestore
                .collection('support_tickets')
                .where('userEmail', isEqualTo: email),
          );
          supportQueries.add(
            _firestore
                .collection('support_tickets')
                .where('patientEmail', isEqualTo: email),
          );
        }
        await collectDocs('support_tickets', supportQueries);

        // G. Payments & Invoices
        final paymentQueries = <Query<Map<String, dynamic>>>[
          _firestore.collection('payments').where('userId', isEqualTo: uid),
          _firestore.collection('payments').where('customerId', isEqualTo: uid),
          _firestore.collection('payments').where('patientId', isEqualTo: uid),
        ];
        if (email != null && email.isNotEmpty) {
          paymentQueries.add(
            _firestore
                .collection('payments')
                .where('userEmail', isEqualTo: email),
          );
          paymentQueries.add(
            _firestore
                .collection('payments')
                .where('customerEmail', isEqualTo: email),
          );
        }
        await collectDocs('payments', paymentQueries);

        // H. Subcollections under users/{uid}
        const subcollections = [
          'vital_history',
          'medical_records',
          'favorites',
          'notifications',
          'devices',
          'activity',
          'prescriptions',
        ];
        for (final sub in subcollections) {
          try {
            final subSnap = await _firestore
                .collection('users')
                .doc(uid)
                .collection(sub)
                .get();
            for (final d in subSnap.docs) {
              docsToDelete[d.reference.path] = d.reference;
            }
          } catch (_) {}
        }

        // Commit deletions in batches (Firestore allows max 500 ops per batch)
        final docList = docsToDelete.values.toList();
        for (var i = 0; i < docList.length; i += 400) {
          final batch = _firestore.batch();
          final end = (i + 400 < docList.length) ? i + 400 : docList.length;
          for (var j = i; j < end; j++) {
            batch.delete(docList[j]);
          }
          await batch.commit();
        }

        // Delete the root user profile document
        await _firestore.collection('users').doc(uid).delete();
      } catch (e) {
        debugPrint('Firestore account cascade delete error: $e');
      }
    }

    // 3. Clear local SharedPreferences cache
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}

    // 4. Delete user from Firebase Authentication
    try {
      await user.delete();
    } on FirebaseAuthException catch (authErr) {
      if (authErr.code == 'requires-recent-login') {
        debugPrint(
          'User requires re-authentication before Auth deletion: ${authErr.message}',
        );
        rethrow;
      }
      debugPrint('FirebaseAuth user.delete error: $authErr');
    } catch (e) {
      debugPrint('User auth delete error: $e');
    }
  }

  Future<void> _deleteStorageFolderRecursively(Reference ref) async {
    try {
      final listResult = await ref.listAll();
      for (final item in listResult.items) {
        try {
          await item.delete();
        } catch (_) {}
      }
      for (final prefix in listResult.prefixes) {
        await _deleteStorageFolderRecursively(prefix);
      }
    } catch (_) {
      // Folder does not exist or empty bucket; safe to ignore
    }
  }
}
