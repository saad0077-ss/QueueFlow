import 'package:flutter/material.dart';

import 'legal_document_section.dart';

const privacyPolicyConfig = LegalDocumentConfig(
  appBarTitle: 'Privacy Policy',
  appBarSubtitle: 'How QueueFlow protects your data',
  heroBadge: 'PATIENT DATA PROTECTION',
  lastUpdated: 'Updated Nov 2026',
  heroTitle: 'Your Privacy Comes First',
  heroDescription:
      'We collect only the details required to book clinic visits, track live queue tokens, and deliver receipts safely.',
  heroIcon: Icons.verified_user_rounded,
  heroGradient: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
  highlights: [
    LegalHighlightBadge(icon: Icons.lock_rounded, label: 'Encrypted Storage'),
    LegalHighlightBadge(icon: Icons.block_rounded, label: 'No Data Selling'),
    LegalHighlightBadge(icon: Icons.tune_rounded, label: 'Full Control'),
  ],
  sections: [
    LegalSectionItem(
      number: '01',
      title: 'Information We Collect',
      summary: 'Essential profile, booking, and live queue records.',
      icon: Icons.badge_outlined,
      accent: Color(0xFF3B82F6),
      bullets: [
        'Account details including name, email, phone number, and optional Health ID.',
        'Health profile preferences you choose to share such as blood group, age, allergies, and emergency contact.',
        'Appointment bookings, live queue tokens, payment receipts, and notification device tokens.',
      ],
    ),
    LegalSectionItem(
      number: '02',
      title: 'How We Use Your Data',
      summary: 'Powering smarter clinic check-ins and real-time updates.',
      icon: Icons.bolt_rounded,
      accent: Color(0xFF10B981),
      bullets: [
        'Reserve doctor time slots and synchronize walk-in or booked queue positions in real time.',
        'Send timely alerts when your queue turn approaches or when a clinic updates your visit status.',
        'Generate verifiable payment invoices, refund records, and verified clinic feedback.',
      ],
    ),
    LegalSectionItem(
      number: '03',
      title: 'Sharing With Clinics',
      summary: 'Shared only with healthcare providers you select.',
      icon: Icons.local_hospital_outlined,
      accent: Color(0xFF8B5CF6),
      bullets: [
        'Partner clinics receive your booking details, selected doctor/service, and check-in token to serve your visit.',
        'We never sell personal or health information to advertisers or third-party data brokers.',
        'Payment processing occurs over secure encrypted checkout gateways without storing raw card credentials.',
      ],
    ),
    LegalSectionItem(
      number: '04',
      title: 'Security & Your Rights',
      summary: 'Update, export, or delete your account whenever you wish.',
      icon: Icons.admin_panel_settings_outlined,
      accent: Color(0xFFF59E0B),
      bullets: [
        'Access and edit personal details, allergies, or reviews directly from your Profile tab.',
        'Toggle notifications or delete published reviews at any time.',
        'Request permanent account removal directly inside Profile under Account Controls.',
      ],
    ),
  ],
);
