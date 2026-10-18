import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'home_active_queue_banner.dart';
import 'home_category_chips.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final bloc = context.read<HomeBloc>();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar
              HomeSearchBar(
                controller: _searchCtrl,
                onChanged: (val) => bloc.add(HomeSearchQueryChanged(val)),
                onClear: () => bloc.add(const HomeSearchQueryChanged('')),
              ),

              // 2. Category Chips
              HomeCategoryChips(
                selectedCategory: state.selectedCategory,
                onCategorySelected: (cat) => bloc.add(HomeCategorySelected(cat)),
              ),
              const SizedBox(height: 16),

              // 3. Active Live Queue Ticket Banner
              if (state.activeTicket != null && state.activeTicket!.isActive) ...[
                HomeActiveQueueBanner( 
                  ticket: state.activeTicket!,
                  onTap: () => bloc.add(const HomeNavTabChanged(1)),
                ),
                const SizedBox(height: 20),
              ],

              // 4. Featured Clinics Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured clinics near you',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                      letterSpacing: -0.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      bloc.add(const HomeCategorySelected('all'));
                    },
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

              // 5. Clinics List
              if (state.filteredClinics.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(36),
                    child: Text(
                      'No clinics found matching your criteria.',
                      style: TextStyle(color: AppColors.darkInkMuted),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.filteredClinics.length,
                  itemBuilder: (ctx, i) {
                    final clinic = state.filteredClinics[i];
                    return HomeClinicCard(
                      clinic: clinic,
                      onTap: () {
                        // Dialog removed as per request
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
