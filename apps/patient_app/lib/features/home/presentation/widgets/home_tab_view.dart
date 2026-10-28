import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../pages/patient_search_screen.dart';
import 'home_active_queue_banner.dart';
import 'home_clinic_card.dart';
import 'home_search_bar.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openSearchScreen(BuildContext context, HomeState state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientSearchScreen(
          allClinics: state.allClinics,
          initialCategory: 'all',
          initialQuery: _searchCtrl.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final bloc = context.read<HomeBloc>();

        return LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool isTablet = width >= 640 && width < 960;
            final bool isDesktop = width >= 960;
            final bool useGrid = width >= 720;
            final double horizontalPadding = isDesktop ? 32 : (isTablet ? 24 : 18);
            final double maxContentWidth = isDesktop ? 960 : (isTablet ? 720 : double.infinity);

            return Column(
              children: [
                // 1. FIXED SEARCH BAR AT THE TOP UNDER APPBAR
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        10,
                        horizontalPadding,
                        12,
                      ),
                      child: HomeSearchBar(
                        controller: _searchCtrl,
                        readOnly: true,
                        margin: EdgeInsets.zero,
                        onTap: () => _openSearchScreen(context, state),
                        onChanged: (val) => bloc.add(HomeSearchQueryChanged(val)),
                        onClear: () => bloc.add(const HomeSearchQueryChanged('')),
                      ),
                    ),
                  ),
                ),

                // 2. SCROLLABLE REST OF THE CONTENT (PULL TO REFRESH)
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryLight,
                    backgroundColor: AppColors.darkSurface,
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
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: 4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Active Live Queue Ticket Banner (if active)
                                if (state.activeTicket != null && state.activeTicket!.isActive) ...[
                                  HomeActiveQueueBanner(
                                    ticket: state.activeTicket!,
                                    onTap: () => bloc.add(const HomeNavTabChanged(1)),
                                  ),
                                ],

                                // Featured Clinics Section Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    const Text(
                                      'Featured clinics near you',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.darkInk,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _openSearchScreen(context, state),
                                      child: Text(
                                        'See all (${state.allClinics.length})',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF38BDF8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Responsive Clinics List or Grid
                                if (state.allClinics.isEmpty)
                                  _buildEmptyState()
                                else if (useGrid)
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: state.allClinics.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isDesktop ? 2 : 2,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      mainAxisExtent: 110,
                                    ),
                                    itemBuilder: (ctx, i) {
                                      final clinic = state.allClinics[i];
                                      return HomeClinicCard(
                                        clinic: clinic,
                                        onTap: () {
                                          _showClinicDetailsModal(context, clinic);
                                        },
                                      );
                                    },
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: state.allClinics.length,
                                    itemBuilder: (ctx, i) {
                                      final clinic = state.allClinics[i];
                                      return HomeClinicCard(
                                        clinic: clinic,
                                        onTap: () {
                                          _showClinicDetailsModal(context, clinic);
                                        },
                                      );
                                    },
                                  ),

                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkBorder),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_hospital_outlined,
                color: AppColors.darkInkFaint,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No clinics available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.darkInk,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No active clinics registered in the database at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darkInkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClinicDetailsModal(BuildContext context, dynamic clinic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    clinic.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkInk,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkInkFaint),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              clinic.category,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF38BDF8),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.darkInkFaint),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${clinic.address}, ${clinic.city}',
                    style: const TextStyle(fontSize: 13, color: AppColors.darkInkMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: AppColors.darkInkFaint),
                const SizedBox(width: 6),
                Text(
                  clinic.phone,
                  style: const TextStyle(fontSize: 13, color: AppColors.darkInkMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule_outlined, size: 16, color: AppColors.darkInkFaint),
                const SizedBox(width: 6),
                Text(
                  clinic.openingHours,
                  style: const TextStyle(fontSize: 13, color: AppColors.darkInkMuted),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: clinic.isOpen ? const Color(0xFF123022) : const Color(0xFF351319),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    clinic.isOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: clinic.isOpen ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    ),
                  ),
                ),
                if (clinic.hasLiveQueue) ...[
                  const SizedBox(width: 10),
                  Text(
                    '${clinic.waitingCount} in live queue',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
