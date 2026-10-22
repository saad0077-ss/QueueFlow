import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/standard_service_entity.dart';

/// Fixed widths shared by the catalog header row and each item row.
const double kCatalogDurationColWidth = 150;
const double kCatalogFeeColWidth = 150;
const double kCatalogActionsColWidth = 200;

/// Accent cycle for the leading procedure tiles.
const _accents = [Color(0xFF3B82F6), Color(0xFF14B8A6), Color(0xFFA855F7), Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF06B6D4)];

class DeptCatalogRowItem extends StatefulWidget {
  final StandardServiceEntity service;
  final ValueChanged<StandardServiceEntity> onEditService;
  final ValueChanged<String> onRemoveService;
  final int index;
  final bool isLast;

  const DeptCatalogRowItem({
    super.key,
    required this.service,
    required this.onEditService,
    required this.onRemoveService,
    this.index = 0,
    this.isLast = false,
  });

  @override
  State<DeptCatalogRowItem> createState() => _DeptCatalogRowItemState();
}

class _DeptCatalogRowItemState extends State<DeptCatalogRowItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final accent = _accents[widget.index % _accents.length];
    final formattedPrice = service.suggestedPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: _hover ? const Color(0xFF15213A).withValues(alpha: 0.6) : Colors.transparent,
          border: Border(
            left: BorderSide(color: _hover ? accent : Colors.transparent, width: 3),
            bottom: widget.isLast ? BorderSide.none : const BorderSide(color: Color(0xFF1E293B)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.medical_services_outlined, size: 19, color: accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF94A3B8), height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            SizedBox(
              width: kCatalogDurationColWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _chip(
                  icon: Icons.schedule_rounded,
                  label: '${service.duration} mins',
                  fg: const Color(0xFFE2E8F0),
                  iconColor: const Color(0xFF94A3B8),
                  bg: const Color(0xFF1E293B),
                ),
              ),
            ),
            SizedBox(
              width: kCatalogFeeColWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '₹$formattedPrice',
                    style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF60A5FA)),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: kCatalogActionsColWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionPill(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      tooltip: 'Edit procedure',
                      color: const Color(0xFF38BDF8),
                      onTap: () => widget.onEditService(service),
                    ),
                    const SizedBox(width: 8),
                    _ActionPill(
                      icon: Icons.delete_outline_rounded,
                      label: 'Remove',
                      tooltip: 'Remove from catalog',
                      color: const Color(0xFFEF4444),
                      onTap: () => widget.onRemoveService(service.id),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({required IconData icon, required String label, required Color fg, required Color iconColor, required Color bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatefulWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _ActionPill({required this.icon, required this.label, required this.tooltip, required this.color, required this.onTap});

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final fg = Color.lerp(color, Colors.white, 0.2)!;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: _hover ? 0.22 : 0.08),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: color.withValues(alpha: _hover ? 0.6 : 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 15, color: fg),
                const SizedBox(width: 5),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
