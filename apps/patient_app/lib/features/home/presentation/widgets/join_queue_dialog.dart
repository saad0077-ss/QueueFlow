import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/clinic_entity.dart';
import 'queue/dialog/join_queue_actions.dart';
import 'queue/dialog/join_queue_bloc.dart';
import 'queue/dialog/join_queue_fee_box.dart';
import 'queue/dialog/join_queue_header.dart';
import 'queue/dialog/join_queue_info_box.dart';

typedef JoinQueueSuccess = void Function(String service, String department);

/// Modal dialog matching `modalJoinQueue`; payment is handled by Razorpay checkout.
class JoinQueueDialog extends StatelessWidget {
  final ClinicEntity clinic;
  final JoinQueueSuccess onJoinSuccess;
  final String? service;
  final String? department;

  const JoinQueueDialog({
    super.key,
    required this.clinic,
    required this.onJoinSuccess,
    this.service,
    this.department,
  });

  static Future<void> show(
    BuildContext context, {
    required ClinicEntity clinic,
    required JoinQueueSuccess onJoinSuccess,
    String? service,
    String? department,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => JoinQueueDialog(
        clinic: clinic,
        onJoinSuccess: onJoinSuccess,
        service: service,
        department: department,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider(
      create: (_) => JoinQueueBloc(
        clinic: clinic,
        presetService: service,
        presetDepartment: department,
      ),
      child: BlocBuilder<JoinQueueBloc, JoinQueueState>(
        builder: (context, state) {
          final bloc = context.read<JoinQueueBloc>();

          return Dialog(
            backgroundColor: colors.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: colors.border),
            ),
            elevation: 16,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  JoinQueueHeader(clinicName: clinic.name),
                  const SizedBox(height: 18),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                    )
                  else ...[
                    JoinQueueInfoBox(
                      department: state.department,
                      service: state.service,
                    ),
                    const SizedBox(height: 14),
                  ],
                  const JoinQueueFeeBox(),
                  const SizedBox(height: 20),
                  JoinQueueActions(
                    canJoin: state.canJoin,
                    onCancel: () => Navigator.of(context).pop(),
                    onProceed: () => bloc.checkout(
                      context: context,
                      onSuccess: onJoinSuccess,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
