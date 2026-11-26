import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'payment_history_filter_button.dart';

class PaymentHistorySearchBar extends StatefulWidget {
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasActiveFilter;
  final VoidCallback? onFilterTap;

  const PaymentHistorySearchBar({
    super.key,
    required this.query,
    required this.onChanged,
    required this.onClear,
    this.hasActiveFilter = false,
    this.onFilterTap,
  });

  @override
  State<PaymentHistorySearchBar> createState() =>
      _PaymentHistorySearchBarState();
}

class _PaymentHistorySearchBarState extends State<PaymentHistorySearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant PaymentHistorySearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.text = widget.query;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search by receipt no, clinic, doctor, token...',
        hintStyle: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20,
          color: colors.textMuted,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        suffixIcon: (widget.query.isEmpty && widget.onFilterTap == null)
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.query.isNotEmpty)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: colors.textMuted,
                        ),
                        onPressed: () {
                          _controller.clear();
                          widget.onClear();
                        },
                      ),
                    if (widget.query.isNotEmpty && widget.onFilterTap != null)
                      Container(
                        width: 1,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        color: colors.border,
                      ),
                    if (widget.onFilterTap != null)
                      PaymentHistoryFilterButton(
                        hasActiveFilter: widget.hasActiveFilter,
                        onTap: widget.onFilterTap!,
                      ),
                  ],
                ),
              ),
        filled: true,
        fillColor: colors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}
