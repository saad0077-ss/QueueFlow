import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/navigation/platform_navigation_helper.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../dashboard/presentation/widgets/console_sidebar.dart';
import '../../../dashboard/presentation/widgets/console_top_bar.dart';
import '../../data/repositories/platform_billing_repository_impl.dart';
import '../bloc/platform_billing_bloc.dart';
import '../bloc/platform_billing_event.dart';
import '../bloc/platform_billing_state.dart';
import '../widgets/platform_billing_scroll_content.dart';

class PlatformBillingPage extends StatelessWidget {
  const PlatformBillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PlatformBillingBloc(repository: PlatformBillingRepositoryImpl())
            ..add(const PlatformBillingStarted()),
      child: const _PlatformBillingView(),
    );
  }
}

class _PlatformBillingView extends StatefulWidget {
  const _PlatformBillingView();

  @override
  State<_PlatformBillingView> createState() => _PlatformBillingViewState();
}

class _PlatformBillingViewState extends State<_PlatformBillingView> {
  void _onSidebarNav(int i) {
    PlatformNavigationHelper.navigateTo(context, i, 3);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return BlocConsumer<PlatformBillingBloc, PlatformBillingState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          if (state.isError) {
            AppSnackBar.showError(context, message: state.feedbackMessage!);
          } else {
            AppSnackBar.showSuccess(context, message: state.feedbackMessage!);
          }
          context.read<PlatformBillingBloc>().add(
            const PlatformBillingFeedbackDismissed(),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<PlatformBillingBloc>();
        final colors = context.colors;

        return Scaffold(
          backgroundColor: colors.background,
          drawer: isDesktop
              ? null
              : Drawer(
                  child: ConsoleSidebar(
                    activeIndex: 3,
                    onIndexChanged: _onSidebarNav,
                  ),
                ),
          body: Row(
            children: [
              if (isDesktop)
                ConsoleSidebar(activeIndex: 3, onIndexChanged: _onSidebarNav),
              Expanded(
                child: Builder(
                  builder: (ctx) => Column(
                    children: [
                      ConsoleTopBar(
                        onMenuPressed: isDesktop
                            ? null
                            : () => Scaffold.of(ctx).openDrawer(),
                      ),
                      Expanded(
                        child: state.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : PlatformBillingScrollContent(
                                state: state,
                                bloc: bloc,
                              ),
                      ),
                    ],
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
