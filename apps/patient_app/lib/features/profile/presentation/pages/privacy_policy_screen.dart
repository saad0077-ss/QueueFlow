import 'package:flutter/material.dart';

import '../widgets/legal/legal_document_screen.dart';
import '../widgets/legal/privacy_policy_content.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(config: privacyPolicyConfig);
  }
}
