import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Compact filter trigger rendered inside [PaymentHistorySearchBar].
class PaymentHistoryFilterButton extends StatelessWidget {
  final bool hasActiveFilter;
  final VoidCallback onTap;

  const PaymentHistoryFilterButton({
    super.key,
    required this.hasActiveFilter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Tooltip(
      message: 'Filter transactions',
      child: InkWell(
        key: const Key('payment_history_filter_button'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: hasActiveFilter
                ? colors.primary.withValues(alpha: 0.14)
                : colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: hasActiveFilter
                  ? colors.primary.withValues(alpha: 0.45)
                  : colors.border,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 18,
                color: hasActiveFilter ? colors.primary : colors.textPrimary,
              ),
              if (hasActiveFilter)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
