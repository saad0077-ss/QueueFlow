import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../domain/entities/active_ticket_entity.dart';
import 'active_ticket_bottom_row.dart';
import 'active_ticket_metric_box.dart';

class ActiveTicketHeroCard extends StatelessWidget {
  final ActiveTicketEntity ticket;

  const ActiveTicketHeroCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
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
                _buildTopRow(),
                const SizedBox(height: 12),
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
                _buildStatsRow(),
                const SizedBox(height: 16),
                ActiveTicketBottomRow(nowServing: ticket.nowServing),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
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
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
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
    );
  }

  Widget _buildStatsRow() {
    final isCalled = ticket.status.toLowerCase() == 'called';
    return Row(
      children: [
        Expanded(
          child: ActiveTicketMetricBox(
            value: isCalled
                ? 'Your turn!'
                : ticket.position <= 0
                    ? "You're next!"
                    : '${ticket.position}',
            label: 'Ahead of you',
            isCompact: ticket.position <= 0 || isCalled,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActiveTicketMetricBox(
            value: '~${ticket.estWaitMin} min',
            label: 'Est. wait',
            isCompact: false,
          ),
        ),
      ],
    );
  }
}
