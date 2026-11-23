import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../../core/widgets/app_snack_bar.dart';
import '../clinic_invite_share_helper.dart';

class ClinicInviteShareOptions extends StatelessWidget {
  final String toEmail;
  final String clinicName;
  final String adminName;
  final String inviteUrl;

  const ClinicInviteShareOptions({
    super.key,
    required this.toEmail,
    required this.clinicName,
    required this.adminName,
    required this.inviteUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFEA4335),
            radius: 18,
            child: Icon(Icons.mail_rounded, color: Colors.white, size: 18),
          ),
          title: Text(
            'Send via Gmail (Web)',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Opens pre-composed invite ready to send',
            style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
          ),
          trailing: const Icon(Icons.open_in_new_rounded, size: 18),
          onTap: () {
            Navigator.pop(context);
            ClinicInviteShareHelper.launchGmail(
              toEmail: toEmail,
              clinicName: clinicName,
              adminName: adminName,
              inviteUrl: inviteUrl,
            );
          },
        ),
        const Divider(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF2563EB),
            radius: 18,
            child: Icon(Icons.email_outlined, color: Colors.white, size: 18),
          ),
          title: Text(
            'Send via Default Mail Client',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Opens Outlook, Apple Mail, or system mail app',
            style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
          ),
          trailing: const Icon(Icons.send_rounded, size: 18),
          onTap: () {
            Navigator.pop(context);
            ClinicInviteShareHelper.launchMailClient(
              toEmail: toEmail,
              clinicName: clinicName,
              adminName: adminName,
              inviteUrl: inviteUrl,
            );
          },
        ),
        const Divider(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: colors.surfaceSecondary,
            radius: 18,
            child: Icon(Icons.copy_rounded, color: colors.textPrimary, size: 18),
          ),
          title: Text(
            'Copy Activation Link',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Share link manually via chat, WhatsApp, or SMS',
            style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
          ),
          trailing: const Icon(Icons.check_rounded, size: 18),
          onTap: () {
            Clipboard.setData(ClipboardData(text: inviteUrl));
            Navigator.pop(context);
            AppSnackBar.showSuccess(
              context,
              message: 'Activation link copied to clipboard!',
            );
          },
        ),
      ],
    );
  }
}
