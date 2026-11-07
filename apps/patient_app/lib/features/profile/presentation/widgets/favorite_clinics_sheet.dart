import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../clinic_details/presentation/pages/clinic_details_screen.dart';
import '../../../home/data/repositories/home_repository_impl.dart';
import '../../../home/domain/entities/clinic_entity.dart';
import '../../../home/presentation/widgets/home_clinic_card.dart';
import '../../domain/entities/favorite_clinic_entity.dart';

class FavoriteClinicsSheet extends StatefulWidget {
  final List<FavoriteClinicEntity> clinics;
  final ValueChanged<FavoriteClinicEntity>? onBookClinic;

  const FavoriteClinicsSheet({
    super.key,
    required this.clinics,
    this.onBookClinic,
  });

  static Future<void> show(
    BuildContext context, {
    required List<FavoriteClinicEntity> clinics,
    ValueChanged<FavoriteClinicEntity>? onBookClinic,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FavoriteClinicsSheet(
        clinics: clinics,
        onBookClinic: onBookClinic,
      ),
    );
  }

  @override
  State<FavoriteClinicsSheet> createState() => _FavoriteClinicsSheetState();
}

class _FavoriteClinicsSheetState extends State<FavoriteClinicsSheet> {
  /// Live clinic data (photo, open state, queue) keyed by clinic id.
  Map<String, ClinicEntity> _live = const {};

  @override
  void initState() {
    super.initState();
    _loadLiveClinics();
  }

  Future<void> _loadLiveClinics() async {
    try {
      final all = await HomeRepositoryImpl().getFeaturedClinics();
      if (!mounted) return;
      setState(() => _live = {for (final c in all) c.id: c});
    } catch (_) {
      // Fall back to the saved snapshot of each favorite.
    }
  }

  /// Live clinic when available, otherwise rebuilt from the saved favorite.
  ClinicEntity _resolve(FavoriteClinicEntity fav) {
    final live = _live[fav.id];
    if (live != null) return live;
    return ClinicEntity(
      id: fav.id,
      name: fav.name,
      initials: fav.initials,
      category: fav.department,
      rating: fav.rating,
      reviewCount: fav.reviewsCount,
      distance: '',
      city: fav.address,
      address: fav.address,
      phone: '',
      consultationFee: '',
      openingHours: '',
    );
  }

  Future<void> _open(FavoriteClinicEntity fav) async {
    final clinic = _resolve(fav);
    final booked = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ClinicDetailsScreen(clinic: clinic)),
    );
    if (booked == true && mounted) {
      Navigator.of(context).pop();
      widget.onBookClinic?.call(fav);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final clinics = widget.clinics;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Favorite Clinics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Quick access to your trusted doctors',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: colors.textMuted, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceSecondary,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Clinics list: same card as the home screen
          Expanded(
            child: ListView.builder(
              itemCount: clinics.length,
              itemBuilder: (context, index) {
                final fav = clinics[index];
                return HomeClinicCard(
                  clinic: _resolve(fav),
                  onTap: () => _open(fav),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
