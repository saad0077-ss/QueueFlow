import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'help_support_faq_data.dart';

class HelpSupportFaqTab extends StatefulWidget {
  const HelpSupportFaqTab({super.key});

  @override
  State<HelpSupportFaqTab> createState() => _HelpSupportFaqTabState();
}

class _HelpSupportFaqTabState extends State<HelpSupportFaqTab> {
  final _searchController = TextEditingController();
  int? _expandedIndex = 0;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final filteredFaqs = HelpSupportFaqData.allFaqs.where((f) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return f['q']!.toLowerCase().contains(q) ||
          f['a']!.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.inter(fontSize: 12.5, color: colors.textPrimary),
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Search FAQs & Help Topics...',
              hintStyle: GoogleFonts.inter(
                fontSize: 12.5,
                color: colors.textMuted,
              ),
              prefixIcon: Icon(Icons.search, size: 18, color: colors.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (filteredFaqs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Text(
                'No FAQs match your search query.',
                style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredFaqs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final faq = filteredFaqs[index];
              final isExpanded = _expandedIndex == index;

              return Container(
                decoration: BoxDecoration(
                  color: isExpanded ? colors.surfaceSecondary : colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isExpanded
                        ? const Color(0xFF2563EB).withValues(alpha: 0.35)
                        : colors.border,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: Key('faq_$index'),
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _expandedIndex = expanded ? index : null;
                        });
                      },
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 2,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      leading: Text(
                        isExpanded ? '💡' : '❓',
                        style: const TextStyle(fontSize: 15),
                      ),
                      title: Text(
                        faq['q']!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isExpanded
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isExpanded
                              ? const Color(0xFF2563EB)
                              : colors.textPrimary,
                        ),
                      ),
                      trailing: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: isExpanded
                            ? const Color(0xFF2563EB)
                            : colors.textMuted,
                        size: 20,
                      ),
                      children: [
                        Text(
                          faq['a']!,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: colors.textMuted,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
