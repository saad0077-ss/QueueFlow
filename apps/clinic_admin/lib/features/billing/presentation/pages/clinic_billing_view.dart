import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/clinic_billing_repository_impl.dart';
import '../../data/services/billing_receipt_pdf.dart';
import '../bloc/clinic_billing_bloc.dart';
import '../bloc/clinic_billing_event.dart';
import '../bloc/clinic_billing_state.dart';
import '../widgets/billing_invoices_table_card.dart';
import '../widgets/billing_upper_section.dart';
import '../widgets/clinic_billing_header.dart';
import '../widgets/clinic_billing_plans_section.dart';

class ClinicBillingView extends StatelessWidget {
  const ClinicBillingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ClinicBillingBloc(repository: ClinicBillingRepositoryImpl())
            ..add(const ClinicBillingStarted()),
      child: const _ClinicBillingBody(),
    );
  }
}

class _ClinicBillingBody extends StatelessWidget {
  const _ClinicBillingBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicBillingBloc, ClinicBillingState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          if (state.isError) {
            AppSnackBar.showError(context, message: state.feedbackMessage!);
          } else {
            AppSnackBar.showSuccess(context, message: state.feedbackMessage!);
          }
          context.read<ClinicBillingBloc>().add(
            const ClinicBillingFeedbackDismissed(),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final sub = state.subscription;
        if (sub == null) {
          return const Center(
            child: Text(
              'Subscription details could not be loaded.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        final bloc = context.read<ClinicBillingBloc>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClinicBillingHeader(
              clinicName: sub.clinicName,
              planName: sub.planName,
              renewalDate: sub.currentPeriodEnd,
              onChangePlan: () {},
            ),
            const SizedBox(height: 24),
            BillingUpperSection(
              subscription: sub,
              currentTier: state.currentTier,
            ),
            const SizedBox(height: 36),
            ClinicBillingPlansSection(bloc: bloc, state: state, sub: sub),
            const SizedBox(height: 32),
            BillingInvoicesTableCard(
              clinicName: sub.clinicName,
              invoices: state.invoices,
              onRefresh: () => bloc.add(const ClinicBillingInvoicesRefreshed()),
              onDownloadInvoice: (inv) async {
                try {
                  await BillingReceiptPdf.download(inv);
                } catch (_) {
                  if (context.mounted) {
                    AppSnackBar.showError(
                      context,
                      message: 'Could not generate the receipt PDF.',
                    );
                  }
                }
              },
              onPayInvoice: (inv) => AppSnackBar.showInfo(
                context,
                message:
                    'Online payment via Razorpay is not set up yet. Please contact QueueFlow support to pay invoice ${inv.number}.',
              ),
            ),
          ],
        );
      },
    );
  }
}
