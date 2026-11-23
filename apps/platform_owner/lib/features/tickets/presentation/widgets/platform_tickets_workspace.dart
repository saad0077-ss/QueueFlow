import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/platform_support_repository_impl.dart';
import '../bloc/platform_tickets_bloc.dart';
import '../bloc/platform_tickets_event.dart';
import '../bloc/platform_tickets_state.dart';
import 'platform_ticket_chat_console.dart';
import 'platform_tickets_workspace_content.dart';

class PlatformTicketsWorkspace extends StatefulWidget {
  final String topBarSearch;

  const PlatformTicketsWorkspace({super.key, this.topBarSearch = ''});

  @override
  State<PlatformTicketsWorkspace> createState() =>
      _PlatformTicketsWorkspaceState();
}

class _PlatformTicketsWorkspaceState extends State<PlatformTicketsWorkspace> {
  final _repository = PlatformSupportRepositoryImpl();
  Timer? _countdownTicker;

  @override
  void initState() {
    super.initState();
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(PlatformTicketsWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.topBarSearch != oldWidget.topBarSearch) {
      context.read<PlatformTicketsBloc>().add(
        PlatformTicketsSearchChanged(widget.topBarSearch),
      );
    }
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformTicketsBloc, PlatformTicketsState>(
      builder: (context, state) {
        final bloc = context.read<PlatformTicketsBloc>();
        final selected = state.selectedTicket;

        if (state.status == PlatformTicketsStatus.loading &&
            state.allTickets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isViewingChat && selected != null) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: PlatformTicketChatConsole(
              key: ValueKey(selected.id),
              initialTicket: selected,
              repository: _repository,
              adminName: 'Platform Admin',
              onBack: () => bloc.add(const PlatformTicketViewChatToggled(false)),
              onTicketDeleted: () {
                bloc.add(const PlatformTicketViewChatToggled(false));
                bloc.add(PlatformTicketDeleteSubmitted(selected.id));
              },
            ),
          );
        }

        return PlatformTicketsWorkspaceContent(state: state);
      },
    );
  }
}
