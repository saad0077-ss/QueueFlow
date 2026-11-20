import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';

class ServiceQueueDetailRowActions extends StatelessWidget {
  final ClinicQueueItemEntity item;
  final ValueChanged<ClinicQueueItemEntity> onSelectPatient;
  final ValueChanged<String> onCallSpecific;
  final ValueChanged<String> onComplete;
  final ValueChanged<String> onSkip;

  const ServiceQueueDetailRowActions({
    super.key,
    required this.item,
    required this.onSelectPatient,
    required this.onCallSpecific,
    required this.onComplete,
    required this.onSkip,
  });

  ButtonStyle _small(AppColorsExtension colors, {Color? fg, Color? bg, Color? side}) =>
      ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 30)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700),
        ),
        foregroundColor: WidgetStatePropertyAll(fg ?? colors.textPrimary),
        backgroundColor: bg == null ? null : WidgetStatePropertyAll(bg),
        elevation: const WidgetStatePropertyAll(0),
        side: side == null
            ? WidgetStatePropertyAll(BorderSide(color: colors.border))
            : WidgetStatePropertyAll(BorderSide(color: side)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isWaiting = item.isWaiting;
    final isCalled = item.isCalled;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWaiting) ...[
            ElevatedButton(
              onPressed: () => onCallSpecific(item.token),
              style: _small(colors, fg: Colors.white, bg: colors.primary),
              child: const Text('Call / Serve'),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: () => onSkip(item.token),
              style: _small(colors),
              child: const Text('Skip'),
            ),
          ] else if (isCalled) ...[
            OutlinedButton(
              onPressed: () => onComplete(item.token),
              style: _small(colors, fg: const Color(0xFF10B981), side: const Color(0xFF10B981)),
              child: const Text('✓ Complete'),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: () => onSkip(item.token),
              style: _small(colors),
              child: const Text('Skip'),
            ),
          ],
          const SizedBox(width: 6),
          OutlinedButton(
            onPressed: () => onSelectPatient(item),
            style: _small(colors),
            child: const Text('Details'),
          ),
        ],
      ),
    );
  }
}
