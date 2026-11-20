import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../domain/entities/active_ticket_entity.dart';

class HomeActiveQueueBannerBody extends StatelessWidget {
  final ActiveTicketEntity ticket;

  const HomeActiveQueueBannerBody({super.key, required this.ticket});

  String get _formattedToken {
    final t = ticket.token.trim();
    if (t.contains('-') && !t.contains(' - ')) {
      return t.replaceFirst('-', ' - ');
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCalled = ticket.status.toLowerCase() == 'called';
    final double progress = ticket.position <= 0
        ? 1.0
        : (isCalled ? 0.90 : 0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formattedToken,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                ticket.position > 0
                    ? '${ticket.position} people ahead'
                    : 'It is your turn!',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(4),
            ),
            clipBehavior: Clip.antiAlias,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'View live tracker',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: colors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
