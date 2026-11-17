import '../../../../core/widgets/clinic_open_builder.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/clinic_dept_chip.dart';
import '../../../../core/widgets/distance_builder.dart';
import '../../../home/domain/entities/clinic_entity.dart';
import 'clinic_status_pill.dart';

class ClinicHeaderInfo extends StatelessWidget {
  final ClinicEntity clinic;
  final String? holidayNotice;

  const ClinicHeaderInfo({
    super.key,
    required this.clinic,
    this.holidayNotice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                clinic.name,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ClinicOpenBuilder(
              clinic: clinic,
              builder: (_, isOpen) => ClinicStatusPill(isOpen: isOpen),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.star_rounded, size: 16, color: colors.ratingGold),
            const SizedBox(width: 4),
            Text(
              clinic.hasRatings ? clinic.rating.toStringAsFixed(1) : 'New',
              style: GoogleFonts.robotoMono(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                clinic.hasRatings
                    ? '(${clinic.reviewCount} review${clinic.reviewCount == 1 ? '' : 's'}) · ${clinic.primaryCategory}'
                    : 'No reviews yet · ${clinic.primaryCategory}',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: colors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ClinicDeptChip(clinic: clinic),
          ],
        ),
        const SizedBox(height: 8),
        _ExpandableAddress(
          address: clinic.address,
          color: colors.textMuted,
          moreColor: colors.primary,
        ),
        DistanceBuilder(
          clinic: clinic,
          builder: (_, dist) => dist.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: _buildInfoRow(
                    icon: Icons.directions_walk_rounded,
                    text: '$dist away',
                    color: colors.textMuted,
                  ),
                ),
        ),
        const SizedBox(height: 5),
        _buildInfoRow(
          icon: Icons.phone_outlined,
          text: clinic.phone,
          color: colors.primary,
          isBold: true,
        ),
        if (clinic.openingHours.trim().isNotEmpty) ...[
          const SizedBox(height: 5),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            text: clinic.openingHours,
            color: colors.textMuted,
          ),
        ],
        if (holidayNotice != null && holidayNotice!.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildHolidayNotice(holidayNotice!, colors),
        ],
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildHolidayNotice(String notice, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.warningTint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
      ),
      child: Text(
        '📢 Notice: $notice',
        style: GoogleFonts.inter(
          fontSize: 11.5,
          color: colors.warning,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Address that clamps to one line and expands/collapses on tap when it is long.
class _ExpandableAddress extends StatefulWidget {
  final String address;
  final Color color;
  final Color moreColor;

  const _ExpandableAddress({
    required this.address,
    required this.color,
    required this.moreColor,
  });

  @override
  State<_ExpandableAddress> createState() => _ExpandableAddressState();
}

class _ExpandableAddressState extends State<_ExpandableAddress> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(fontSize: 12.5, color: widget.color);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Room left for the icon (14) and gap (6) before the text.
        final textWidth = constraints.maxWidth - 20;
        final painter = TextPainter(
          text: TextSpan(text: widget.address, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: textWidth);
        final overflows = painter.didExceedMaxLines;

        return InkWell(
          onTap: overflows ? () => setState(() => _expanded = !_expanded) : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.location_on_outlined, size: 14, color: widget.color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.topLeft,
                  child: Text.rich(
                    TextSpan(
                      style: style,
                      children: [
                        TextSpan(text: widget.address),
                        if (overflows && _expanded)
                          TextSpan(
                            text: '  less',
                            style: style.copyWith(
                              color: widget.moreColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    maxLines: _expanded || !overflows ? null : 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
              if (overflows && !_expanded)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    'more',
                    style: style.copyWith(
                      color: widget.moreColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
