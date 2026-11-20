import 'package:equatable/equatable.dart';

import '../../domain/entities/favorite_clinic_entity.dart';
import '../../domain/entities/patient_payment_item_entity.dart';
import '../../domain/entities/patient_profile_entity.dart';
import '../../domain/entities/patient_queue_history_entity.dart';
import '../../domain/entities/patient_review_entity.dart';
import '../../domain/entities/support_ticket_entity.dart';

enum ProfileStatus { initial, loading, loaded, updating, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final PatientProfileEntity? profile;
  final List<FavoriteClinicEntity> favoriteClinics;
  final List<PatientReviewEntity> userReviews;
  final List<SupportTicketEntity> supportTickets;
  final List<PatientQueueHistoryEntity> queueHistory;
  final List<PatientPaymentItemEntity> paymentHistory;
  final String? activeTicketId;
  final String? errorMessage;
  final String? successMessage;
  final bool isLoggedOut;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.favoriteClinics = const [],
    this.userReviews = const [],
    this.supportTickets = const [],
    this.queueHistory = const [],
    this.paymentHistory = const [],
    this.activeTicketId,
    this.errorMessage,
    this.successMessage,
    this.isLoggedOut = false,
  });

  bool get isLoading => status == ProfileStatus.loading || status == ProfileStatus.updating;

  String? get error => errorMessage;

  PatientQueueHistoryEntity? get activeQueueTicket =>
      queueHistory.where((q) => q.isActive).firstOrNull;

  double get totalAmountPaid => paymentHistory
      .where((p) => p.isPaid)
      .fold(0.0, (sum, p) => sum + p.amount);

  SupportTicketEntity? get activeTicket {
    if (supportTickets.isEmpty) return null;
    if (activeTicketId != null) {
      final found = supportTickets
          .where((t) => t.id == activeTicketId)
          .toList();
      if (found.isNotEmpty) return found.first;
    }
    return supportTickets.first;
  }

  ProfileState copyWith({
    ProfileStatus? status,
    PatientProfileEntity? profile,
    List<FavoriteClinicEntity>? favoriteClinics,
    List<PatientReviewEntity>? userReviews,
    List<SupportTicketEntity>? supportTickets,
    List<PatientQueueHistoryEntity>? queueHistory,
    List<PatientPaymentItemEntity>? paymentHistory,
    String? activeTicketId,
    String? errorMessage,
    String? successMessage,
    bool? isLoggedOut,
    bool clearMessages = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      favoriteClinics: favoriteClinics ?? this.favoriteClinics,
      userReviews: userReviews ?? this.userReviews,
      supportTickets: supportTickets ?? this.supportTickets,
      queueHistory: queueHistory ?? this.queueHistory,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      activeTicketId: activeTicketId ?? this.activeTicketId,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages
          ? null
          : (successMessage ?? this.successMessage),
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    favoriteClinics,
    userReviews,
    supportTickets,
    queueHistory,
    paymentHistory,
    activeTicketId,
    errorMessage,
    successMessage,
    isLoggedOut,
  ];
}
