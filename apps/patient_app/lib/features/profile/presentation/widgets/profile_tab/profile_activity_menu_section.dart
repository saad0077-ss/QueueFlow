import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:patient_app/features/profile/presentation/pages/booking_history_screen.dart';
import 'package:patient_app/features/profile/presentation/pages/favorite_clinics_screen.dart';
import 'package:patient_app/features/profile/presentation/pages/live_queue_history_screen.dart';
import 'package:patient_app/features/profile/presentation/pages/my_reviews_screen.dart';
import 'package:patient_app/features/profile/presentation/pages/payment_history_screen.dart';

import '../profile_menu_section.dart';

class ProfileActivityMenuSection extends StatelessWidget {
  final ProfileState state;
  final VoidCallback? onVisitsTap;
  final VoidCallback? onTrackLiveQueue;

  const ProfileActivityMenuSection({
    super.key,
    required this.state,
    this.onVisitsTap,
    this.onTrackLiveQueue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final profile = state.profile!;
    final bloc = context.read<ProfileBloc>();

    return ProfileMenuSection(
      title: 'Activity & Records',
      items: [
        ProfileMenuItem(
          icon: const Text('🎟️', style: TextStyle(fontSize: 16)),
          iconBgColor: AppColors.primary.withValues(alpha: 0.15),
          title: 'Joined Live Queue History',
          subtitle: 'Tokens, live triage wait times & status',
          trailing: _badge(
            state.activeQueueTicket != null
                ? const Color(0xFF10B981)
                : AppColors.primary,
            state.activeQueueTicket != null
                ? '● ${state.activeQueueTicket!.token} Active'
                : '${state.queueHistory.length} Joined',
            colors,
          ),
          onTap: () => LiveQueueHistoryScreen.open(
            context,
            onTrackLiveQueue: onTrackLiveQueue,
            onBookClinic: (_) => onVisitsTap?.call(),
          ),
        ),
        ProfileMenuItem(
          icon: const Text('📅', style: TextStyle(fontSize: 16)),
          iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.15),
          title: 'Booking History',
          subtitle: 'Upcoming, completed & past appointments',
          trailing: _badge(
            const Color(0xFF10B981),
            '${profile.visitsCount} Visits',
            colors,
          ),
          onTap: () => BookingHistoryScreen.open(
            context,
            onTrackLiveQueue: onTrackLiveQueue,
            onBookClinic: (_) => onVisitsTap?.call(),
          ),
        ),
        ProfileMenuItem(
          icon: const Text('💳', style: TextStyle(fontSize: 16)),
          iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          title: 'Payment History',
          subtitle: 'Consultation fees, receipts & refunds',
          trailing: _badge(
            const Color(0xFF8B5CF6),
            '₹${state.totalAmountPaid.toStringAsFixed(0)}',
            colors,
          ),
          onTap: () => PaymentHistoryScreen.open(context),
        ),
        ProfileMenuItem(
          icon: const Text('⭐', style: TextStyle(fontSize: 16)),
          iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
          title: 'My Ratings & Reviews',
          subtitle: 'Clinic feedback & verified ratings',
          trailing: _badge(
            const Color(0xFFF59E0B),
            '${state.userReviews.length} Reviews',
            colors,
          ),
          onTap: () => MyReviewsScreen.open(
            context,
            initialReviews: state.userReviews,
            onDeleteCallback: (id) => bloc.add(ProfileReviewDeleted(id)),
          ),
        ),
        ProfileMenuItem(
          icon: const Icon(
            Icons.favorite_rounded,
            size: 18,
            color: Color(0xFF14B8A6),
          ),
          iconBgColor: const Color(0xFF14B8A6).withValues(alpha: 0.15),
          title: 'Favorite clinics',
          subtitle: 'Bookmarked healthcare centers',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${state.favoriteClinics.length} Clinics',
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.textSubtle,
              ),
            ],
          ),
          onTap: () => FavoriteClinicsScreen.open(
            context,
            initialClinics: state.favoriteClinics,
            onBookClinic: onVisitsTap != null
                ? (_) => onVisitsTap?.call()
                : null,
            onQueueClinic: onTrackLiveQueue != null
                ? (_) => onTrackLiveQueue?.call()
                : null,
          ),
        ),
      ],
    );
  }

  Widget _badge(Color color, String text, dynamic colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded, size: 18, color: colors.textSubtle),
      ],
    );
  }
}
