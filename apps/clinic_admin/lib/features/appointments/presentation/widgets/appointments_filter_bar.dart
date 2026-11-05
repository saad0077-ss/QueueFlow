import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class AppointmentsFilterBar extends StatefulWidget {
  final String searchQuery;
  final String selectedDateRange;
  final String selectedDept;
  final String selectedService;
  final String selectedDoctor;
  final String selectedStatus;
  final String selectedPayment;
  final List<String> availableDepts;
  final List<String> availableServices;
  final List<String> availableDoctors;
  final int totalCount;
  final int filteredCount;
  final bool hasActiveFilters;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onDateRangeChanged;
  final ValueChanged<String> onDeptChanged;
  final ValueChanged<String> onServiceChanged;
  final ValueChanged<String> onDoctorChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPaymentChanged;
  final VoidCallback onClearFilters;

  const AppointmentsFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedDateRange,
    required this.selectedDept,
    required this.selectedService,
    required this.selectedDoctor,
    required this.selectedStatus,
    required this.selectedPayment,
    required this.availableDepts,
    required this.availableServices,
    required this.availableDoctors,
    required this.totalCount,
    required this.filteredCount,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onDateRangeChanged,
    required this.onDeptChanged,
    required this.onServiceChanged,
    required this.onDoctorChanged,
    required this.onStatusChanged,
    required this.onPaymentChanged,
    required this.onClearFilters,
  });

  @override
  State<AppointmentsFilterBar> createState() => _AppointmentsFilterBarState();
}

class _AppointmentsFilterBarState extends State<AppointmentsFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant AppointmentsFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync when the query is cleared from outside (e.g. "Clear").
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount => [
    widget.selectedDateRange,
    widget.selectedDept,
    widget.selectedService,
    widget.selectedDoctor,
    widget.selectedStatus,
    widget.selectedPayment,
  ].where((v) => v != 'all').length;

  Future<void> _openFilterDialog() async {
    final colors = context.colors;
    String date = widget.selectedDateRange;
    String status = widget.selectedStatus;
    String payment = widget.selectedPayment;

    String valid(String v, List<String> options) =>
        options.contains(v) ? v : 'all';
    final depts = widget.availableDepts;
    final services = widget.availableServices;
    final doctors = widget.availableDoctors;
    String dept = valid(widget.selectedDept, depts);
    String service = valid(widget.selectedService, services);
    String doctor = valid(widget.selectedDoctor, doctors);

    Widget field(String label, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(width: double.infinity, child: child),
        ],
      ),
    );

    List<DropdownMenuItem<String>> items(List<String> opts, String allLabel) =>
        opts
            .map(
              (o) => DropdownMenuItem(
                value: o,
                child: Text(o == 'all' ? allLabel : o),
              ),
            )
            .toList();

    DropdownMenuItem<String> item(String v, String label) =>
        DropdownMenuItem(value: v, child: Text(label));

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Dialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.border),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Appointments',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: colors.textMuted,
                          splashRadius: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    field(
                      'Date',
                      _FilterDropdown<String>(
                        value: date,
                        items: [
                          item('all', 'All Dates'),
                          item('today', 'Today'),
                          item('week', 'This Week'),
                        ],
                        onChanged: (v) => setLocal(() => date = v ?? date),
                      ),
                    ),
                    field(
                      'Department',
                      _FilterDropdown<String>(
                        value: dept,
                        items: items(depts, 'All Departments'),
                        onChanged: (v) => setLocal(() => dept = v ?? dept),
                      ),
                    ),
                    field(
                      'Service',
                      _FilterDropdown<String>(
                        value: service,
                        items: items(services, 'All Services'),
                        onChanged: (v) =>
                            setLocal(() => service = v ?? service),
                      ),
                    ),
                    field(
                      'Doctor',
                      _FilterDropdown<String>(
                        value: doctor,
                        items: items(doctors, 'All Doctors'),
                        onChanged: (v) => setLocal(() => doctor = v ?? doctor),
                      ),
                    ),
                    field(
                      'Status',
                      _FilterDropdown<String>(
                        value: status,
                        items: [
                          item('all', 'All Statuses'),
                          item('confirmed', 'Confirmed'),
                          item('upcoming', 'Upcoming'),
                          item('checkedin', 'Checked In'),
                          item('completed', 'Completed'),
                          item('cancelled', 'Cancelled'),
                        ],
                        onChanged: (v) => setLocal(() => status = v ?? status),
                      ),
                    ),
                    field(
                      'Payment',
                      _FilterDropdown<String>(
                        value: payment,
                        items: [
                          item('all', 'All Payments'),
                          item('paid', 'Paid'),
                          item('refunded', 'Refunded'),
                          item('due', 'Due'),
                        ],
                        onChanged: (v) =>
                            setLocal(() => payment = v ?? payment),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => setLocal(() {
                            date = dept = service = doctor = status = payment =
                                'all';
                          }),
                          child: Text(
                            'Reset',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (date != widget.selectedDateRange) {
                              widget.onDateRangeChanged(date);
                            }
                            if (dept != widget.selectedDept) {
                              widget.onDeptChanged(dept);
                            }
                            if (service != widget.selectedService) {
                              widget.onServiceChanged(service);
                            }
                            if (doctor != widget.selectedDoctor) {
                              widget.onDoctorChanged(doctor);
                            }
                            if (status != widget.selectedStatus) {
                              widget.onStatusChanged(status);
                            }
                            if (payment != widget.selectedPayment) {
                              widget.onPaymentChanged(payment);
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Apply Filters',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = _activeFilterCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1.2),
      ),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _searchController,
                onChanged: (v) {
                  widget.onSearchChanged(v);
                  setState(() {});
                },
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search patient, booking ID, doctor, phone...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: colors.textMuted,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: colors.textMuted,
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          color: colors.textMuted,
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearchChanged('');
                            setState(() {});
                          },
                        ),
                  filled: true,
                  fillColor: colors.surfaceSecondary,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.primary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Filter button
          InkWell(
            onTap: _openFilterDialog,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: count > 0 ? colors.primaryTint : colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: count > 0 ? colors.primary : colors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    size: 16,
                    color: count > 0 ? colors.primary : colors.textPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    count > 0 ? 'Filters ($count)' : 'Filters',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: count > 0 ? colors.primary : colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Clear Button
          if (widget.hasActiveFilters) ...[
            const SizedBox(width: 10),
            InkWell(
              onTap: widget.onClearFilters,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: colors.surface,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            size: 18,
            color: colors.textMuted,
          ),
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
