import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/favorite_clinic_entity.dart';
import 'favorite_clinic_actions_row.dart';
import 'favorite_clinic_header_row.dart';
import 'favorite_clinic_meta_row.dart';

class FavoriteClinicCard extends StatelessWidget {
  final FavoriteClinicEntity clinic;
  final VoidCallback onUnfavorite;
  final VoidCallback onBook;
  final VoidCallback onLiveQueue;
  final VoidCallback onCall;

  const FavoriteClinicCard({
    super.key,
    required this.clinic,
    required this.onUnfavorite,
    required this.onBook,
    required this.onLiveQueue,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shortAddr = clinic.address.trim().isNotEmpty
        ? clinic.address.split(',').first.trim()
        : '';
    final hasHours = clinic.openHours.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FavoriteClinicHeaderRow(clinic: clinic, onUnfavorite: onUnfavorite),
          const SizedBox(height: 12),
          FavoriteClinicMetaRow(clinic: clinic),
          if (hasHours || shortAddr.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasHours)
                  Flexible(
                    child: Text(
                      '🕒 ${clinic.openHours}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: colors.textMuted,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (shortAddr.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      shortAddr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 12),
          FavoriteClinicActionsRow(
            hasPhone: clinic.phone.trim().isNotEmpty,
            onBook: onBook,
            onLiveQueue: onLiveQueue,
            onCall: onCall,
          ),
        ],
      ),
    );
  }
}
