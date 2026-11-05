import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PolicyTermsDialog extends StatelessWidget {
  final bool isPrivacyPolicy; // true for Privacy Policy, false for Terms of Service

  const PolicyTermsDialog({
    super.key,
    required this.isPrivacyPolicy,
  });

  static Future<void> showPrivacyPolicy(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const PolicyTermsDialog(isPrivacyPolicy: true),
    );
  }

  static Future<void> showTermsOfService(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const PolicyTermsDialog(isPrivacyPolicy: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = isPrivacyPolicy ? 'Privacy Policy' : 'Terms of Service';
    final subtitle = isPrivacyPolicy ? 'Last updated: January 2026' : 'Effective from January 2026';
    final buttonText = isPrivacyPolicy ? 'I Understand' : 'Agree & Close';

    return Dialog(
      backgroundColor: colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.border, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 480,
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.textMuted, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.surfaceSecondary,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Legal Sections Scroll
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: isPrivacyPolicy
                      ? _buildPrivacySections(context)
                      : _buildTermsSections(context),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Dismiss Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPrivacySections(BuildContext context) {
    return [
      _buildParagraph(
        context,
        num: '1',
        heading: 'Information We Collect',
        body: 'QueueFlow collects your contact details (name, email, phone number) and medical queue metadata to facilitate seamless outpatient appointments.',
      ),
      _buildParagraph(
        context,
        num: '2',
        heading: 'Health Data Protection',
        body: 'All clinic visits and prescription identifiers are encrypted end-to-end adhering to global digital healthcare privacy standards.',
      ),
      _buildParagraph(
        context,
        num: '3',
        heading: 'Location Services',
        body: 'We only access your precise device location when estimating queue travel ETA or navigating to a clinic.',
      ),
      _buildParagraph(
        context,
        num: '4',
        heading: 'Third-Party Sharing',
        body: 'We never sell your personal information. Clinic records are shared exclusively with your booked healthcare provider.',
      ),
    ];
  }

  List<Widget> _buildTermsSections(BuildContext context) {
    return [
      _buildParagraph(
        context,
        num: '1',
        heading: 'Patient Obligations',
        body: 'Users agree to provide accurate phone numbers for queue dispatch notifications and arrive promptly when their token is called.',
      ),
      _buildParagraph(
        context,
        num: '2',
        heading: 'Queue Token Validity',
        body: 'Digital queue tokens are valid only for the selected clinic day and doctor schedule. Unattended tokens are voided after the standard clinic grace period.',
      ),
      _buildParagraph(
        context,
        num: '3',
        heading: 'Cancellation Policy',
        body: 'Appointments can be rescheduled or cancelled freely up to 1 hour before the scheduled time slot.',
      ),
      _buildParagraph(
        context,
        num: '4',
        heading: 'Emergency Medical Care',
        body: 'QueueFlow is an outpatient appointment scheduling tool. For life-threatening emergencies, immediately dial 112 or visit the nearest ER.',
      ),
    ];
  }

  Widget _buildParagraph(BuildContext context, {required String num, required String heading, required String body}) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$num. $heading',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: TextStyle(
              fontSize: 12,
              color: colors.textMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
