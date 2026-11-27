import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../bloc/profile_state.dart';
import '../../pages/booking_history_screen.dart';
import '../../pages/favorite_clinics_screen.dart';
import '../../pages/live_queue_history_screen.dart';
import '../../pages/my_reviews_screen.dart';
import '../../pages/payment_history_screen.dart';
import '../profile_menu_section.dart';
import 'profile_menu_badge.dart';

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

  ProfileMenuItem _item(
    BuildContext context, {
    required Widget icon,
    required Color color,
    required String title,
    required String subtitle,
    required String badgeText,
    required Future<void> Function() onOpen,
  }) {
    return ProfileMenuItem(
      icon: icon,
      iconBgColor: color.withValues(alpha: 0.15),
      title: title,
      subtitle: subtitle,
      trailing: ProfileMenuBadge(color: color, text: badgeText),
      onTap: () async {
        await onOpen();
        if (context.mounted) {
          context.read<ProfileBloc>().add(const ProfileLoadRequested());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = state.profile!;
    final hasActive = state.activeQueueTicket != null;

    return ProfileMenuSection(
      title: 'Activity & Records',
      items: [
        _item(
          context,
          icon: const Text('🎟️', style: TextStyle(fontSize: 16)),
          color: hasActive ? const Color(0xFF10B981) : AppColors.primary,
          title: 'Live Queue',
          subtitle: 'Tokens & status',
          badgeText: hasActive
              ? '● ${state.activeQueueTicket!.token} Active'
              : '${state.queueHistory.length} Joined',
          onOpen: () => LiveQueueHistoryScreen.open(
            context,
            onTrackLiveQueue: onTrackLiveQueue,
            onBookClinic: (_) => onVisitsTap?.call(),
          ),
        ),
        _item(
          context,
          icon: const Text('📅', style: TextStyle(fontSize: 16)),
          color: const Color(0xFF10B981),
          title: 'Booking History',
          subtitle: 'Your appointments',
          badgeText: '${profile.visitsCount} Visits',
          onOpen: () => BookingHistoryScreen.open(
            context,
            onTrackLiveQueue: onTrackLiveQueue,
            onBookClinic: (_) => onVisitsTap?.call(),
          ),
        ),
        _item(
          context,
          icon: const Text('💳', style: TextStyle(fontSize: 16)),
          color: const Color(0xFF8B5CF6),
          title: 'Payment History',
          subtitle: 'Receipts & refunds',
          badgeText: '₹${state.totalAmountPaid.toStringAsFixed(0)}',
          onOpen: () => PaymentHistoryScreen.open(context),
        ),
        _item(
          context,
          icon: const Text('⭐', style: TextStyle(fontSize: 16)),
          color: const Color(0xFFF59E0B),
          title: 'My Reviews',
          subtitle: 'Ratings & feedback',
          badgeText: '${state.userReviews.length} Reviews',
          onOpen: () => MyReviewsScreen.open(
            context,
            onDeleteCallback: (id) {
              if (context.mounted) {
                context.read<ProfileBloc>().add(ProfileReviewDeleted(id));
              }
            },
          ),
        ),
        _item(
          context,
          icon: const Icon(
            Icons.favorite_rounded,
            size: 18,
            color: Color(0xFF14B8A6),
          ),
          color: const Color(0xFF14B8A6),
          title: 'Favorite Clinics',
          subtitle: 'Saved clinics',
          badgeText: '${state.favoriteClinics.length} Clinics',
          onOpen: () => FavoriteClinicsScreen.open(
            context,
            initialClinics: state.favoriteClinics,
            onBookClinic: onVisitsTap != null ? (_) => onVisitsTap?.call() : null,
            onQueueClinic:
                onTrackLiveQueue != null ? (_) => onTrackLiveQueue?.call() : null,
          ),
        ),
      ],
    );
  }
}
