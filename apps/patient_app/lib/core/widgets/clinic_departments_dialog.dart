import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/home/domain/entities/clinic_entity.dart';
import '../theme/app_colors.dart';
import 'clinic_department_item.dart';

void showClinicDepartmentsDialog(BuildContext context, {required ClinicEntity clinic}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => ClinicDepartmentsDialog(clinic: clinic),
  );
}

class ClinicDepartmentsDialog extends StatefulWidget {
  final ClinicEntity clinic;

  const ClinicDepartmentsDialog({super.key, required this.clinic});

  @override
  State<ClinicDepartmentsDialog> createState() => _ClinicDepartmentsDialogState();
}

class _ClinicDepartmentsDialogState extends State<ClinicDepartmentsDialog> {
  List<ClinicDepartmentItemData> _items = [];

  @override
  void initState() {
    super.initState();
    _buildItems();
  }

  void _buildItems() {
    final depts = widget.clinic.departmentList;
    _items = depts.map((d) => ClinicDepartmentItemData.fromName(d)).toList();

    FirebaseFirestore.instance.collection('departments').get().then((snap) {
      if (snap.docs.isNotEmpty && mounted) {
        final Map<String, Map<String, dynamic>> map = {};
        for (var doc in snap.docs) {
          final data = doc.data();
          map[(data['name'] ?? '').toString().toLowerCase()] = data;
          map[(data['code'] ?? '').toString().toLowerCase()] = data;
        }
        setState(() {
          _items = depts.map((d) {
            final fData = map[d.toLowerCase()] ?? map[d.toLowerCase().split(' ').first];
            return ClinicDepartmentItemData.fromName(d, firestoreData: fData);
          }).toList();
        });
      }
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 4, decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_items.length} DEPARTMENTS',
                          style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.accent),
                        ),
                        const SizedBox(height: 2),
                        Text('Departments', style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.darkInk)),
                        const SizedBox(height: 2),
                        Text(widget.clinic.name, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.darkInkMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.darkInkMuted, size: 20),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                itemCount: _items.length,
                itemBuilder: (ctx, i) => ClinicDepartmentCardWidget(data: _items[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
