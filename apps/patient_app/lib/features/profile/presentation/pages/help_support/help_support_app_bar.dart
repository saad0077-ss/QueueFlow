import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';

class HelpSupportAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HelpSupportAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: colors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Help & Support Desk',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          Text(
            'Live queue triage, inquiries & care coordination',
            style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          color: colors.textMuted,
          tooltip: 'Refresh',
          onPressed: () =>
              context.read<ProfileBloc>().add(const ProfileLoadRequested()),
        ),
      ],
    );
  }
}
