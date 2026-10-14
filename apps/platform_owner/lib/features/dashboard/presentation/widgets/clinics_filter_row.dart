import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClinicsFilterRow extends StatelessWidget {
  final String searchQuery;
  final String selectedPlan;
  final String selectedStatus;
  final int count;
  final int total;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onPlanChanged;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onReset;

  const ClinicsFilterRow({
    super.key,
    required this.searchQuery,
    required this.selectedPlan,
    required this.selectedStatus,
    required this.count,
    required this.total,
    required this.onSearch,
    required this.onPlanChanged,
    required this.onStatusChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final searchBox = _searchBox();
        final planDropdown = _dropdown(selectedPlan, const ['All Plans', 'Solo Doctor Plan', 'Multi-Doctor Clinic Plan', 'Enterprise Practice'], onPlanChanged);
        final statusDropdown = _dropdown(selectedStatus, const ['All Statuses', 'ACTIVE', 'INVITED', 'TRIAL', 'SUSPENDED'], onStatusChanged);
        final resetBtn = _resetPill();
        final countText = Text('Showing $count of $total clinics', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)));

        final compactContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            searchBox,
            const SizedBox(height: 10),
            Row(children: [Expanded(child: planDropdown), const SizedBox(width: 8), Expanded(child: statusDropdown)]),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [countText, resetBtn]),
          ],
        );

        final desktopContent = Row(
          children: [
            Expanded(flex: 3, child: searchBox),
            const SizedBox(width: 10),
            Expanded(flex: 3, child: planDropdown),
            const SizedBox(width: 10),
            Expanded(flex: 3, child: statusDropdown),
            const SizedBox(width: 14),
            countText,
            const SizedBox(width: 10),
            resetBtn,
          ],
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: isCompact ? compactContent : desktopContent,
        );
      },
    );
  }

  Widget _searchBox() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF162238),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF26354D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onSearch,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
              decoration: InputDecoration(
                hintText: 'Search by clinic name, doctor, city, plan...',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12.5),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String value, List<String> items, ValueChanged<String> onChanged) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF162238),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF26354D)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          dropdownColor: const Color(0xFF162238),
          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8), size: 18),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (v) => onChanged(v ?? items.first),
        ),
      ),
    );
  }

  Widget _resetPill() {
    return InkWell(
      onTap: onReset,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF162238),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF26354D)),
        ),
        child: Text('Reset Filters', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
