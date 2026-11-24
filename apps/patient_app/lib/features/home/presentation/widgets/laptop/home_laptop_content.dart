import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../../profile/presentation/pages/favorite_clinics_screen.dart';
import '../../../../profile/presentation/pages/help_support/help_support_screen.dart';
import '../../../domain/entities/active_ticket_entity.dart';
import '../../../domain/entities/clinic_entity.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';
import '../../bloc/home_state.dart';
import '../home_clinic_card.dart';
import '../home_search_bar.dart';
import '../queue/radar/live_pulsing_dot.dart';

/// 2-Column Split Dashboard layout exclusively designed for Laptop viewports.
class HomeLaptopContent extends StatefulWidget {
  final HomeState state;
  final ValueChanged<ClinicEntity> onClinicTap;
  final VoidCallback onSearchTap;
  final VoidCallback onTrackLiveQueue;
  final VoidCallback onViewBookings;

  const HomeLaptopContent({
    super.key,
    required this.state,
    required this.onClinicTap,
    required this.onSearchTap,
    required this.onTrackLiveQueue,
    required this.onViewBookings,
  });

  @override
  State<HomeLaptopContent> createState() => _HomeLaptopContentState();
}

class _HomeLaptopContentState extends State<HomeLaptopContent> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'all';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ClinicEntity> get _filteredClinics {
    if (_selectedCategory == 'all') return widget.state.allClinics;
    final cat = _selectedCategory.toLowerCase();
    return widget.state.allClinics.where((c) {
      final clinicCat = c.category.toLowerCase();
      final name = c.name.toLowerCase();
      return clinicCat.contains(cat) || name.contains(cat);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ticket = widget.state.activeTicket;
    final hasActiveTicket = ticket != null && ticket.isActive;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT MAIN PANEL (Clinics Directory & Search, flex: 64)
          Expanded(
            flex: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                HomeSearchBar(
                  controller: _searchCtrl,
                  readOnly: true,
                  margin: EdgeInsets.zero,
                  onTap: widget.onSearchTap,
                  onChanged: (val) =>
                      context.read<HomeBloc>().add(HomeSearchQueryChanged(val)),
                  onClear: () =>
                      context.read<HomeBloc>().add(const HomeSearchQueryChanged('')),
                ),
                const SizedBox(height: 14),

                // Category Filter Pills
                _buildCategoryFilters(colors),
                const SizedBox(height: 18),

                // Section Title + Count Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Verified Medical Clinics',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_filteredClinics.length} available',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2-Column Grid of Clinics
                Expanded(
                  child: _filteredClinics.isEmpty
                      ? _buildEmptyState(colors)
                      : GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredClinics.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            mainAxisExtent: 160,
                          ),
                          itemBuilder: (context, index) {
                            final clinic = _filteredClinics[index];
                            return HomeClinicCard(
                              clinic: clinic,
                              margin: EdgeInsets.zero,
                              onTap: () => widget.onClinicTap(clinic),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // RIGHT SIDE PANEL (Live Queue Status & Shortcuts, flex: 36)
          SizedBox(
            width: 340,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. LIVE QUEUE SPOTLIGHT CARD
                  if (hasActiveTicket)
                    _buildActiveTicketSideCard(context, colors, ticket)
                  else
                    _buildQueueRadarPromoCard(context, colors),

                  const SizedBox(height: 16),

                  // 2. QUICK SHORTCUTS CARD
                  _buildQuickShortcutsCard(context, colors),

                  const SizedBox(height: 16),

                  // 3. APPOINTMENTS ACTION CARD
                  _buildUpcomingAppointmentCard(context, colors),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(AppColorsExtension colors) {
    const categories = [
      {'key': 'all', 'label': 'All Clinics', 'icon': Icons.apps_rounded},
      {'key': 'general', 'label': 'General Medicine', 'icon': Icons.medical_services_rounded},
      {'key': 'dent', 'label': 'Dental Care', 'icon': Icons.health_and_safety_rounded},
      {'key': 'derm', 'label': 'Dermatology', 'icon': Icons.water_drop_rounded},
      {'key': 'pedi', 'label': 'Pediatrics', 'icon': Icons.child_care_rounded},
      {'key': 'ortho', 'label': 'Orthopedics', 'icon': Icons.accessibility_new_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat['key'] as String),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withValues(alpha: 0.15)
                      : colors.surfaceSecondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 15,
                      color: isSelected ? colors.primary : colors.textSubtle,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? colors.primary : colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveTicketSideCard(
    BuildContext context,
    AppColorsExtension colors,
    ActiveTicketEntity ticket,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.15),
            colors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    LivePulsingDot(),
                    SizedBox(width: 5),
                    Text(
                      'ACTIVE IN QUEUE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Est. ${ticket.estWaitMin} mins',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            ticket.clinicName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Doctor consultation for ${ticket.serviceName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricChip(
                colors: colors,
                title: 'YOUR TOKEN',
                value: ticket.token,
                highlight: true,
              ),
              _buildMetricChip(
                colors: colors,
                title: 'NOW SERVING',
                value: ticket.nowServing,
              ),
              _buildMetricChip(
                colors: colors,
                title: 'AHEAD OF YOU',
                value: '${ticket.position}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onTrackLiveQueue,
              icon: const Icon(Icons.radar_rounded, size: 16),
              label: const Text('Track Live Queue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required AppColorsExtension colors,
    required String title,
    required String value,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight ? colors.primary.withValues(alpha: 0.4) : colors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: colors.textMuted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: highlight ? colors.primary : colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueRadarPromoCard(BuildContext context, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.radar_rounded, color: colors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Queue Radar',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'Zero-wait walk-in appointments',
                      style: TextStyle(fontSize: 11, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Skip waiting room lines. Check live clinic queues nearby and join instantly from your laptop.',
            style: TextStyle(fontSize: 12, color: colors.textSubtle, height: 1.4),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: widget.onTrackLiveQueue,
            icon: const Icon(Icons.arrow_forward_rounded, size: 14),
            label: const Text('Check Real-time Wait Times'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size.fromHeight(38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickShortcutsCard(BuildContext context, AppColorsExtension colors) {
    final profileState = context.watch<ProfileBloc>().state;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Shortcuts',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildShortcutTile(
            icon: Icons.favorite_border_rounded,
            title: 'Saved Favorite Clinics',
            subtitle: '${profileState.favoriteClinics.length} clinics saved',
            onTap: () => FavoriteClinicsScreen.open(
              context,
              initialClinics: profileState.favoriteClinics,
            ),
            colors: colors,
          ),
          const Divider(height: 12),
          _buildShortcutTile(
            icon: Icons.confirmation_number_outlined,
            title: 'My Consultation Passes',
            subtitle: 'Upcoming & completed visits',
            onTap: widget.onViewBookings,
            colors: colors,
          ),
          const Divider(height: 12),
          _buildShortcutTile(
            icon: Icons.headset_mic_outlined,
            title: 'Raise a Support Concern',
            subtitle: 'Direct help with tickets',
            onTap: () {
              final profileBloc = context.read<ProfileBloc>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: profileBloc,
                    child: const HelpSupportScreen(initialTabIndex: 1),
                  ),
                ),
              );
            },
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required AppColorsExtension colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: colors.textPrimary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10.5, color: colors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 16, color: colors.textSubtle),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointmentCard(BuildContext context, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Instant Consultation',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Need to see a doctor today? Pick any clinic and book a timed slot or walk in immediately.',
            style: TextStyle(fontSize: 11.5, color: colors.textSubtle, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColorsExtension colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.local_hospital_outlined,
                color: colors.textSubtle,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No clinics matching "$_selectedCategory"',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try selecting "All Clinics" or searching with a different term.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
