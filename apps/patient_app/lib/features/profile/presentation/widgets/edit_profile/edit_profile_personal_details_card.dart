import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'edit_profile_bloc.dart';

class EditProfilePersonalDetailsCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;

  const EditProfilePersonalDetailsCard({
    super.key,
    required this.nameController,
    required this.ageController,
  });

  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  static const List<String> bloodGroupOptions = [
    'A+ Positive',
    'A- Negative',
    'B+ Positive',
    'B- Negative',
    'AB+ Positive',
    'AB- Negative',
    'O+ Positive',
    'O- Negative',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyle = TextStyle(
      fontSize: 14,
      color: colors.textPrimary,
      fontWeight: FontWeight.w500,
    );

    return BlocBuilder<EditProfileBloc, EditProfileState>(
      builder: (context, state) {
        final bloc = context.read<EditProfileBloc>();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: colors.primaryTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'PERSONAL DETAILS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                style: textStyle,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: _inputDeco(
                  context,
                  'Full name',
                  Icons.person_outline_rounded,
                  'Your full name',
                ),
                onChanged: bloc.updateName,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter your name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: ageController,
                style: textStyle,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDeco(
                  context,
                  'Age',
                  Icons.cake_outlined,
                  'Your age',
                ),
                onChanged: bloc.updateAge,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return null;
                  final n = int.tryParse(t);
                  if (n == null || n < 0 || n > 120) {
                    return 'Enter an age between 0 and 120';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: genderOptions.contains(state.gender)
                    ? state.gender
                    : null,
                decoration: _inputDeco(
                  context,
                  'Gender',
                  Icons.wc_rounded,
                  'Select gender',
                ),
                items: genderOptions
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: bloc.updateGender,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: bloodGroupOptions.contains(state.bloodGroup)
                    ? state.bloodGroup
                    : null,
                decoration: _inputDeco(
                  context,
                  'Blood group',
                  Icons.bloodtype_outlined,
                  'Select blood group',
                ),
                items: bloodGroupOptions
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: bloc.updateBloodGroup,
              ),
            ],
          ),
        );
      },
    );
  }

  static InputDecoration _inputDeco(
    BuildContext context,
    String label,
    IconData icon,
    String hint,
  ) {
    final colors = context.colors;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      prefixIconColor: colors.textMuted,
      labelStyle: TextStyle(color: colors.textMuted),
      hintStyle: TextStyle(color: colors.textSubtle),
      filled: true,
      fillColor: colors.surfaceSecondary,
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
    );
  }
}
