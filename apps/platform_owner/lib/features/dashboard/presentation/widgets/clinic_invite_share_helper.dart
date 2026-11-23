import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'invite_share/clinic_invite_share_dialog.dart';

class ClinicInviteShareHelper {
  static String buildEmailBody({
    required String clinicName,
    required String adminName,
    required String inviteUrl,
  }) {
    return 'Hello $adminName,\n\n'
        'You have been invited to manage $clinicName on QueueFlow.\n\n'
        'To activate your clinic admin account and start managing appointments, queues, and doctors, please click the link below:\n\n'
        '$inviteUrl\n\n'
        'Best regards,\n'
        'QueueFlow Platform Operations';
  }

  static Future<void> launchGmail({
    required String toEmail,
    required String clinicName,
    required String adminName,
    required String inviteUrl,
  }) async {
    final body = buildEmailBody(
      clinicName: clinicName,
      adminName: adminName,
      inviteUrl: inviteUrl,
    );
    final subject = 'Invitation to Manage $clinicName on QueueFlow';
    final gmailUrl = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1'
      '&to=${Uri.encodeComponent(toEmail)}'
      '&su=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}',
    );
    await launchUrl(gmailUrl, mode: LaunchMode.externalApplication);
  }

  static Future<void> launchMailClient({
    required String toEmail,
    required String clinicName,
    required String adminName,
    required String inviteUrl,
  }) async {
    final body = buildEmailBody(
      clinicName: clinicName,
      adminName: adminName,
      inviteUrl: inviteUrl,
    );
    final subject = 'Invitation to Manage $clinicName on QueueFlow';
    final mailtoUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      queryParameters: {'subject': subject, 'body': body},
    );
    await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
  }

  static Future<void> showInviteShareModal(
    BuildContext context, {
    required String toEmail,
    required String clinicName,
    required String adminName,
    required String inviteUrl,
    bool emailDelivered = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => ClinicInviteShareDialog(
        toEmail: toEmail,
        clinicName: clinicName,
        adminName: adminName,
        inviteUrl: inviteUrl,
        emailDelivered: emailDelivered,
      ),
    );
  }
}
