import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_state.dart';
import 'concern_detail_chat_screen.dart';
import 'help_support_app_bar.dart';
import 'help_support_concerns_list_tab.dart';
import 'help_support_faq_tab.dart';
import 'help_support_hero_banner.dart';
import 'help_support_nav_tabs.dart';
import 'help_support_raise_concern_tab.dart';

class HelpSupportScreen extends StatefulWidget {
  final int initialTabIndex;
  final String? initialClinicId;
  final String? initialClinicName;
  final String? initialTokenNumber;

  const HelpSupportScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialClinicId,
    this.initialClinicName,
    this.initialTokenNumber,
  });

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  late HelpSupportTab _activeTab;

  @override
  void initState() {
    super.initState();
    if (widget.initialTabIndex == 1) {
      _activeTab = HelpSupportTab.raise;
    } else if (widget.initialTabIndex == 2) {
      _activeTab = HelpSupportTab.faq;
    } else {
      _activeTab = HelpSupportTab.concerns;
    }
  }

  void _onTicketSelected(String ticketId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: ConcernDetailChatScreen(ticketId: ticketId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final ticketCount = state.supportTickets.length;

        return Scaffold(
          backgroundColor: colors.surface,
          appBar: const HelpSupportAppBar(),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HelpSupportHeroBanner(),
                const SizedBox(height: 14),
                HelpSupportNavTabs(
                  activeTab: _activeTab,
                  concernsCount: ticketCount,
                  onTabChanged: (tab) => setState(() => _activeTab = tab),
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _buildActiveTabContent(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveTabContent(ProfileState state) {
    switch (_activeTab) {
      case HelpSupportTab.concerns:
        return HelpSupportConcernsListTab(
          key: const ValueKey('concerns_list_tab'),
          tickets: state.supportTickets,
          onSelectTicket: (ticket) => _onTicketSelected(ticket.id),
          onGoToRaise: () => setState(() => _activeTab = HelpSupportTab.raise),
        );
      case HelpSupportTab.raise:
        return HelpSupportRaiseConcernTab(
          key: const ValueKey('raise_concern_tab'),
          initialClinicId: widget.initialClinicId,
          initialClinicName: widget.initialClinicName,
          initialTokenNumber: widget.initialTokenNumber,
          onConcernSubmitted: () =>
              setState(() => _activeTab = HelpSupportTab.concerns),
        );
      case HelpSupportTab.faq:
        return const HelpSupportFaqTab(key: ValueKey('faq_tab'));
    }
  }
}
