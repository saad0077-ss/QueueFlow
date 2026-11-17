import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/clinic_dept_chip.dart';
import '../../../../core/widgets/distance_builder.dart';
import '../../../../core/widgets/clinic_photo.dart';
import '../../domain/entities/active_ticket_entity.dart';
import '../../domain/entities/clinic_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'cancel_queue_dialog.dart';
import 'join_queue_dialog.dart';

/// Digital Queue Tab matching Screen 9 (`#scr-queue-tracker`) of the QueueFlow prototype.
class LiveQueueTabView extends StatelessWidget {
  const LiveQueueTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final bloc = context.read<HomeBloc>();
        final ticket = state.activeTicket;
        final hasActiveTicket = ticket != null && ticket.isActive;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(
            context,
            hasActiveTicket: hasActiveTicket,
            unreadCount: state.unreadNotificationsCount,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final bool isTablet = width >= 640 && width < 960;
              final bool isDesktop = width >= 960;
              final double horizontalPadding = isDesktop
                  ? 32
                  : (isTablet ? 24 : 18);
              final double maxContentWidth = isDesktop
                  ? 960
                  : (isTablet ? 720 : double.infinity);

              return RefreshIndicator(
                color: colors.primary,
                backgroundColor: colors.surface,
                onRefresh: () async {
                  bloc.add(const HomeRefreshRequested());
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          14,
                          horizontalPadding,
                          24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Main View Content
                            if (hasActiveTicket)
                              _ActiveTicketView(
                                ticket: ticket,
                                allClinics: state.allClinics,
                                onCancelSpot: () async {
                                  final confirmed =
                                      await CancelQueueDialog.show(context);
                                  if (confirmed == true && context.mounted) {
                                    bloc.add(
                                      HomeCancelTicketRequested(ticket.id),
                                    );
                                  }
                                },
                                onGetDirections: (clinic) =>
                                    _openGoogleMaps(context, clinic),
                              )
                            else
                              _QueueRadarView(
                                allClinics: state.allClinics,
                                userName: state.userName,
                                onJoinClinic: (clinic) {
                                  JoinQueueDialog.show(
                                    context,
                                    clinic: clinic,
                                    onJoinSuccess: () {
                                      bloc.add(
                                        HomeJoinQueueRequested(
                                          clinic: clinic,
                                          patientName: state.userName,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context, {
    required bool hasActiveTicket,
    required int unreadCount,
  }) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.headerBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      toolbarHeight: 64,
      titleSpacing: 20,
      title: Text(
        'Live Queue',
        style: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: colors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        if (hasActiveTicket)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? const Color(0xFF133633)
                  : colors.accentTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _LivePulsingDot(),
                const SizedBox(width: 5),
                Text(
                  'Live',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.isDarkMode
                        ? const Color(0xFF2DD4BF)
                        : colors.accent,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// ACTIVE TICKET VIEW (When user has active ticket)
// =============================================================================

class _ActiveTicketView extends StatelessWidget {
  final ActiveTicketEntity ticket;
  final List<ClinicEntity> allClinics;
  final VoidCallback onCancelSpot;
  final ValueChanged<ClinicEntity> onGetDirections;

  const _ActiveTicketView({
    required this.ticket,
    required this.allClinics,
    required this.onCancelSpot,
    required this.onGetDirections,
  });

  ClinicEntity get _associatedClinic {
    final match = allClinics.where((c) => c.id == ticket.clinicId).firstOrNull;
    if (match != null) return match;
    return ClinicEntity(
      id: ticket.clinicId,
      name: ticket.clinicName,
      initials: ticket.clinicName.isNotEmpty
          ? ticket.clinicName.substring(0, 1)
          : 'C',
      category: ticket.serviceName,
      rating: 4.8,
      reviewCount: 120,
      distance: '',
      city: 'Kochi',
      address: '14 MG Road, Palarivattom, Kochi, Kerala',
      phone: '+91 98460 12345',
      consultationFee: '₹100',
      openingHours: '09:00 AM - 08:00 PM',
      currentToken: ticket.nowServing,
      waitingCount: ticket.position,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Ticket Hero Banner
        _buildHeroBanner(context),
        const SizedBox(height: 24),

        // 2. Section Title
        Text(
          'Queue status',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 18),

        // 3. Status Stepper Timeline
        _buildTimeline(context),
        const SizedBox(height: 16),

        // 4. Updates Automatically Notice
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _LivePulsingDot(),
            const SizedBox(width: 8),
            Text(
              'Updates automatically in real time',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textSubtle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // 5. Action Buttons Col
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => onGetDirections(_associatedClinic),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Get Directions',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onCancelSpot,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.error, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            backgroundColor: colors.error.withValues(alpha: 0.04),
          ),
          child: Text(
            'Leave / Cancel Spot',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x472563EB),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Radial glow background watermark
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: Clinic name & Live badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        ticket.clinicName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5.5,
                            height: 5.5,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Live',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Large Token Display
                Text(
                  ticket.token,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 46,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              ticket.position <= 0
                                  ? "You're next!"
                                  : '${ticket.position}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: ticket.position <= 0 ? 14 : 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ahead of you',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '~${ticket.estWaitMin} min',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Est. wait',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bottom row: Now serving + Paid badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Now serving: ',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                        Text(
                          ticket.nowServing.isNotEmpty
                              ? ticket.nowServing
                              : 'A-021',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        '✓ PAID · ₹100 (Razorpay)',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFA7F3D0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final colors = context.colors;
    final isCalled = ticket.status.toLowerCase() == 'called';
    final isCompleted = ticket.status.toLowerCase() == 'completed';

    // 5 Steps matching prototype screenshot
    final steps = [
      _TimelineStep(
        label: 'Token Issued & Paid\n(Razorpay)',
        isDone: true,
        isActive: false,
      ),
      _TimelineStep(
        label: 'Waiting\nin Queue',
        isDone: isCompleted || isCalled || ticket.position <= 1,
        isActive: !isCompleted && !isCalled && ticket.position > 1,
      ),
      _TimelineStep(
        label: 'Almost\nyour turn',
        isDone: isCompleted || isCalled,
        isActive:
            !isCompleted &&
            !isCalled &&
            ticket.position <= 1 &&
            ticket.position > 0,
      ),
      _TimelineStep(
        label: 'Called for\nConsultation',
        isDone: isCompleted,
        isActive: !isCompleted && (isCalled || ticket.position <= 0),
      ),
      _TimelineStep(label: 'Completed', isDone: isCompleted, isActive: false),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final prevStep = steps[i ~/ 2];
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 6),
                height: 2,
                color: prevStep.isDone
                    ? const Color(0xFF10B981)
                    : colors.border,
              ),
            );
          } else {
            final step = steps[i ~/ 2];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTimelineDot(context, step),
                const SizedBox(height: 6),
                SizedBox(
                  width: 64,
                  child: Text(
                    step.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: step.isActive
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: step.isActive
                          ? colors.primary
                          : (step.isDone
                                ? colors.textPrimary
                                : colors.textSubtle),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  Widget _buildTimelineDot(BuildContext context, _TimelineStep step) {
    final colors = context.colors;

    if (step.isDone) {
      return Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: Color(0xFF10B981),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
      );
    }

    if (step.isActive) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      );
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: colors.border, width: 2),
      ),
    );
  }
}

class _TimelineStep {
  final String label;
  final bool isDone;
  final bool isActive;

  const _TimelineStep({
    required this.label,
    required this.isDone,
    required this.isActive,
  });
}

// =============================================================================
// QUEUE RADAR VIEW (When user has no active ticket)
// =============================================================================

class _QueueRadarView extends StatelessWidget {
  final List<ClinicEntity> allClinics;
  final String userName;
  final ValueChanged<ClinicEntity> onJoinClinic;

  const _QueueRadarView({
    required this.allClinics,
    required this.userName,
    required this.onJoinClinic,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Recommended Express Queue Card

        // 2. Section Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Live Clinic Wait Times',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            Row(
              children: [
                const _LivePulsingDot(),
                const SizedBox(width: 5),
                Text(
                  'Real-time',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: context.isDarkMode
                        ? const Color(0xFF2DD4BF)
                        : colors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 3. Radar Clinics List
        if (openClinics.isEmpty)
          _buildEmptyRadar(context)
        else
          ...openClinics.map((clinic) => _buildRadarClinicCard(context, clinic)),
      ],
    );
  }

  /// Clinics outside their operating hours have no live queue to show.
  List<ClinicEntity> get openClinics =>
      allClinics.where((c) => c.isOpenNow).toList();

  Widget _buildRadarClinicCard(BuildContext context, ClinicEntity clinic) {
    final colors = context.colors;
    final waitMin = clinic.waitingCount * 5 > 0 ? clinic.waitingCount * 5 : 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDarkMode ? 0.2 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Avatar + Name/Depts + Waiting Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar circle or Clinic Photo
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: ClinicPhoto(
                    clinicId: clinic.id,
                    imageVersion: clinic.imageVersion,
                    imageUrl: clinic.imageUrl,
                    placeholder: Container(
                      color: colors.primaryTint,
                      alignment: Alignment.center,
                      child: Text(
                        clinic.initials,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (clinic.hasMultipleDepartments)
                          // Tappable "N Depts" chip opens the departments list.
                          ClinicDeptChip(clinic: clinic, margin: EdgeInsets.zero)
                        else
                          _buildInfoChip(
                            context,
                            icon: Icons.medical_services_outlined,
                            label: clinic.primaryCategory,
                          ),
                        DistanceBuilder(
                          clinic: clinic,
                          builder: (ctx, dist) => dist.isEmpty
                              ? const SizedBox.shrink()
                              : _buildInfoChip(
                                  ctx,
                                  icon: Icons.location_on_outlined,
                                  label: dist,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? const Color(0xFF133633)
                      : colors.accentTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _LivePulsingDot(),
                    const SizedBox(width: 4),
                    Text(
                      '${clinic.waitingCount} waiting',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: context.isDarkMode
                            ? const Color(0xFF2DD4BF)
                            : colors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mid Box: Now serving + Est wait
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Now serving: ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colors.textMuted,
                      ),
                    ),
                    Text(
                      clinic.currentToken,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '~$waitMin min wait',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.isDarkMode
                        ? const Color(0xFF2DD4BF)
                        : colors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Join Digital Queue Button
          ElevatedButton(
            onPressed: () => onJoinClinic(clinic),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Join Digital Queue',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.textMuted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRadar(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Text('🏥', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              'No active queues available right now',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Clinics near you will appear here when their digital triage queue opens.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// REUSABLE LIVE PULSING DOT
// =============================================================================

class _LivePulsingDot extends StatefulWidget {
  const _LivePulsingDot();

  @override
  State<_LivePulsingDot> createState() => _LivePulsingDotState();
}

class _LivePulsingDotState extends State<_LivePulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = context.isDarkMode
        ? const Color(0xFF2DD4BF)
        : const Color(0xFF10B981);

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Opens Google Maps (app or browser) with directions to the clinic.
Future<void> _openGoogleMaps(BuildContext context, ClinicEntity clinic) async {
  final messenger = ScaffoldMessenger.of(context);
  final query = [clinic.name, clinic.address, clinic.city]
      .where((e) => e.trim().isNotEmpty)
      .join(', ');
  final uri = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': query,
    'travelmode': 'driving',
  });
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!opened) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open Google Maps.')),
    );
  }
}
