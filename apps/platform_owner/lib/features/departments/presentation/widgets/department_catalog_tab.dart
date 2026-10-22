import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/standard_service_entity.dart';
import 'add_procedure_form_card.dart';
import 'dept_catalog_row_item.dart';

class DepartmentCatalogTab extends StatefulWidget {
  final List<StandardServiceEntity> services;
  final ValueChanged<StandardServiceEntity> onAddService;
  final ValueChanged<StandardServiceEntity> onEditService;
  final ValueChanged<String> onRemoveService;

  const DepartmentCatalogTab({
    super.key,
    required this.services,
    required this.onAddService,
    required this.onEditService,
    required this.onRemoveService,
  });

  @override
  State<DepartmentCatalogTab> createState() => _DepartmentCatalogTabState();
}

class _DepartmentCatalogTabState extends State<DepartmentCatalogTab> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.services.where((s) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return s.name.toLowerCase().contains(q) || s.description.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddProcedureFormCard(onAddService: widget.onAddService, existingServices: widget.services),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1526),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeader(filtered.length), _buildTable(filtered)]),
        ),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF14B8A6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 19, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Active Catalog Procedures',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        '$count',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF34D399)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Standard clinical procedures available to clinics under this specialty',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 270,
            child: TextField(
              style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
              cursorColor: Colors.white,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Filter procedures...',
                hintStyle: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF94A3B8)),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(Icons.search_rounded, size: 17, color: Color(0xFF60A5FA)),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFF15213A),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF2A3A57)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF2A3A57)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<StandardServiceEntity> list) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1E293B))),
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 30, color: Color(0xFF475569)),
            const SizedBox(height: 8),
            Text('No procedures match your filter.', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8))),
          ],
        ),
      );
    }
    final headerStyle = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF64748B), letterSpacing: 0.8, height: 1.35);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: constraints.maxWidth < 760 ? 760 : constraints.maxWidth,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(23, 12, 20, 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF0A1120),
                  border: Border(
                    top: BorderSide(color: Color(0xFF1E293B)),
                    bottom: BorderSide(color: Color(0xFF1E293B)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text('PROCEDURE & CLINICAL SCOPE', style: headerStyle)),
                    SizedBox(
                      width: kCatalogDurationColWidth,
                      child: Text('DURATION', style: headerStyle),
                    ),
                    SizedBox(
                      width: kCatalogFeeColWidth,
                      child: Text('BASE FEE', style: headerStyle),
                    ),
                    SizedBox(
                      width: kCatalogActionsColWidth,
                      child: Text('ACTIONS', textAlign: TextAlign.right, style: headerStyle),
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < list.length; i++)
                DeptCatalogRowItem(
                  service: list[i],
                  onEditService: widget.onEditService,
                  onRemoveService: widget.onRemoveService,
                  index: i,
                  isLast: i == list.length - 1,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
