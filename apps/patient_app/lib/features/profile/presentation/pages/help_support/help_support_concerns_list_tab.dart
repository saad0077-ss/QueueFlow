import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/support_ticket_entity.dart';
import 'help_support_concern_card.dart';
import 'help_support_filter_pills.dart';
import 'help_support_metrics_strip.dart';

class HelpSupportConcernsListTab extends StatefulWidget {
  final List<SupportTicketEntity> tickets;
  final ValueChanged<SupportTicketEntity> onSelectTicket;
  final VoidCallback onGoToRaise;

  const HelpSupportConcernsListTab({
    super.key,
    required this.tickets,
    required this.onSelectTicket,
    required this.onGoToRaise,
  });

  @override
  State<HelpSupportConcernsListTab> createState() =>
      _HelpSupportConcernsListTabState();
}

class _HelpSupportConcernsListTabState
    extends State<HelpSupportConcernsListTab> {
  String _filter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final allTickets = widget.tickets;

    final inProgressCount = allTickets
        .where((t) => t.status != 'resolved')
        .length;
    final resolvedCount = allTickets
        .where((t) => t.status == 'resolved')
        .length;

    final filtered = allTickets.where((t) {
      if (_filter == 'active' && t.status == 'resolved') return false;
      if (_filter == 'resolved' && t.status != 'resolved') return false;

      if (_searchQuery.isNotEmpty) {
        final matchId = t.ticketNumber.toLowerCase().contains(_searchQuery);
        final matchSub = t.subject.toLowerCase().contains(_searchQuery);
        final matchClinic = t.clinicName.toLowerCase().contains(_searchQuery);
        final matchToken = (t.linkedTokenNumber ?? '').toLowerCase().contains(
          _searchQuery,
        );
        if (!matchId && !matchSub && !matchClinic && !matchToken) return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HelpSupportMetricsStrip(
          totalCount: allTickets.length,
          inProgressCount: inProgressCount,
          resolvedCount: resolvedCount,
        ),
        const SizedBox(height: 14),
        HelpSupportFilterPills(
          activeFilter: _filter,
          onFilterChanged: (f) => setState(() => _filter = f),
          totalCount: allTickets.length,
          inProgressCount: inProgressCount,
          resolvedCount: resolvedCount,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            onChanged: (q) =>
                setState(() => _searchQuery = q.trim().toLowerCase()),
            style: GoogleFonts.inter(fontSize: 12.5, color: colors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search by Ticket ID, subject, or clinic...',
              hintStyle: GoogleFonts.inter(
                fontSize: 12,
                color: colors.textMuted,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 16,
                color: colors.textMuted,
              ),
              filled: true,
              fillColor: colors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          _buildEmptyState(colors)
        else
          _buildList(filtered),
      ],
    );
  }

  Widget _buildList(List<SupportTicketEntity> list) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => HelpSupportConcernCard(
        ticket: list[index],
        onTap: () => widget.onSelectTicket(list[index]),
      ),
    );
  }

  Widget _buildEmptyState(AppColorsExtension colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 28,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Concerns Found',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty
                ? 'No inquiries match "$_searchQuery".'
                : 'You have not raised any concerns yet.',
            style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onGoToRaise,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Raise a Concern Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0072FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
