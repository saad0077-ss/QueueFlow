import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'legal_document_header.dart';
import 'legal_document_hero.dart';
import 'legal_document_section.dart';
import 'legal_laptop_layout.dart';
import 'legal_section_card.dart';

/// Reusable responsive screen scaffold for Privacy Policy and Terms screens.
class LegalDocumentScreen extends StatefulWidget {
  final LegalDocumentConfig config;

  const LegalDocumentScreen({super.key, required this.config});

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  late Set<int> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = Set<int>.from(
      List<int>.generate(widget.config.sections.length, (i) => i),
    );
  }

  bool get _allExpanded =>
      _expanded.length == widget.config.sections.length;

  void _toggleAll() {
    setState(() {
      if (_allExpanded) {
        _expanded.clear();
      } else {
        _expanded = Set<int>.from(
          List<int>.generate(widget.config.sections.length, (i) => i),
        );
      }
    });
  }

  void _toggleSection(int index) {
    setState(() {
      if (!_expanded.remove(index)) _expanded.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = widget.config;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LegalDocumentHeader(
              title: c.appBarTitle,
              subtitle: c.appBarSubtitle,
              allExpanded: _allExpanded,
              onBack: () => Navigator.of(context).pop(),
              onToggleAll: _toggleAll,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLaptop = constraints.maxWidth >= 960;
                  final isTablet = constraints.maxWidth >= 700;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLaptop ? 32 : (isTablet ? 24 : 16),
                      vertical: isLaptop ? 24 : 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isLaptop ? 1240 : 720,
                        ),
                        child: isLaptop
                            ? LegalLaptopLayout(
                                config: c,
                                expanded: _expanded,
                                onToggleSection: _toggleSection,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  LegalDocumentHero(config: c),
                                  const SizedBox(height: 16),
                                  for (var i = 0; i < c.sections.length; i++)
                                    LegalSectionCard(
                                      section: c.sections[i],
                                      isExpanded: _expanded.contains(i),
                                      onToggle: () => _toggleSection(i),
                                    ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
