import 'package:flutter/material.dart';

import '../widgets/legal/legal_document_screen.dart';
import '../widgets/legal/terms_conditions_content.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(config: termsConditionsConfig);
  }
}
