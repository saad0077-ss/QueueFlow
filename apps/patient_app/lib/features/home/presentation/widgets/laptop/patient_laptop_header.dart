import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../../profile/presentation/pages/help_support/help_support_screen.dart';
import '../queue/radar/live_pulsing_dot.dart';

/// Top desktop/laptop header bar with breadcrumb context, live status and quick actions.
class PatientLaptopHeader extends StatelessWidget {
  final int currentTabIndex;
  final String userName;
  final int unreadNotifications;
  final String? activeToken;
  final VoidCallback onLiveQueueTap;

  const PatientLaptopHeader({
    super.key,
    required this.currentTabIndex,
    required this.userName,
    this.unreadNotifications = 0,
    this.activeToken,
    required this.onLiveQueueTap,
  });

  String _titleForTab(int tab) {
    switch (tab) {
      case 0:
        final greeting = _timeGreeting();
        final name = userName.trim().isNotEmpty ? userName.split(' ').first : 'Patient';
        return '$greeting, $name';
      case 1:
        return 'Live Digital Queue Tracker';
      case 2:
        return 'My Medical Bookings';
      case 3:
        return 'Patient Health Record & Profile';
      default:
        return 'QueueFlow Portal';
    }
  }

  String _subtitleForTab(int tab) {
    switch (tab) {
      case 0:
        return 'Browse verified clinics, check live doctor wait times, or join a digital line.';
      case 1:
        return 'Real-time token countdown, live clinic radar, and turn notifications.';
      case 2:
        return 'View your upcoming appointments, consultation passes, and receipts.';
      case 3:
        return 'Manage personal medical data, emergency info, and account settings.';
      default:
        return '';
    }
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _openHelpSupport(BuildContext context) {
    try {
      final profileBloc = context.read<ProfileBloc>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: profileBloc,
            child: const HelpSupportScreen(),
          ),
        ),
      );
    } catch (_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const HelpSupportScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.border.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Dynamic Tab Title & Subtitle
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _titleForTab(currentTabIndex),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitleForTab(currentTabIndex),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Active Queue Quick Badge
          if (activeToken != null) ...[
            InkWell(
              onTap: onLiveQueueTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LivePulsingDot(),
                    const SizedBox(width: 8),
                    Text(
                      'Live Spot: $activeToken',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Help & Support button
          OutlinedButton.icon(
            onPressed: () => _openHelpSupport(context),
            icon: Icon(Icons.help_outline_rounded, size: 16, color: colors.textPrimary),
            label: Text(
              'Help & Support',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),

          const SizedBox(width: 10),

          // Notifications Bell
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border.withValues(alpha: 0.6)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: colors.textPrimary,
                ),
                if (unreadNotifications > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
