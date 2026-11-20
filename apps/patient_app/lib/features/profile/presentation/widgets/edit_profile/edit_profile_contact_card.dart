import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'edit_profile_cubit.dart';

class EditProfileContactCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const EditProfileContactCard({
    super.key,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<EditProfileCubit>();
    final textStyle = TextStyle(
      fontSize: 14,
      color: colors.textPrimary,
      fontWeight: FontWeight.w500,
    );

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
                child: Icon(Icons.contact_phone_rounded, size: 16, color: colors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'CONTACT',
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
            controller: emailController,
            style: textStyle,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDeco(context, 'Email address', Icons.mail_outline_rounded, 'name@email.com'),
            onChanged: cubit.updateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: phoneController,
            style: textStyle,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            decoration: _inputDeco(context, 'Phone number', Icons.phone_outlined, '+91 00000 00000'),
            onChanged: cubit.updatePhone,
          ),
        ],
      ),
    );
  }

  static InputDecoration _inputDeco(BuildContext context, String label, IconData icon, String hint) {
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.primary, width: 1.5)),
    );
  }
}
