import 'package:flutter/material.dart';

import 'legal_document_section.dart';

const termsConditionsConfig = LegalDocumentConfig(
  appBarTitle: 'Terms & Conditions',
  appBarSubtitle: 'Service rules, queues & payments',
  heroBadge: 'QUEUEFLOW PATIENT TERMS',
  lastUpdated: 'Effective Nov 2026',
  heroTitle: 'Clear Terms for Every Visit',
  heroDescription:
      'Transparent guidelines covering appointment scheduling, live queue tokens, consultation fees, and patient conduct.',
  heroIcon: Icons.gavel_rounded,
  heroGradient: [Color(0xFF1E1B4B), Color(0xFF4C1D95), Color(0xFF6D28D9)],
  highlights: [
    LegalHighlightBadge(icon: Icons.event_available_rounded, label: 'Verified Slots'),
    LegalHighlightBadge(icon: Icons.schedule_rounded, label: 'Fair Queues'),
    LegalHighlightBadge(icon: Icons.receipt_long_rounded, label: 'Clear Refunds'),
  ],
  sections: [
    LegalSectionItem(
      number: '01',
      title: 'Platform Use & Eligibility',
      summary: 'Accurate patient identity keeps clinic queues reliable.',
      icon: Icons.person_outline_rounded,
      accent: Color(0xFF8B5CF6),
      bullets: [
        'Provide accurate contact details when creating your account or booking a medical consultation.',
        'Do not submit automated, duplicate, or fraudulent bookings that block care slots for other patients.',
        'Keep your login credentials secure; you are responsible for actions taken under your signed-in account.',
      ],
    ),
    LegalSectionItem(
      number: '02',
      title: 'Bookings & Live Queue Rules',
      summary: 'Queue tracking unlocks on your visit day during open hours.',
      icon: Icons.confirmation_number_outlined,
      accent: Color(0xFF2563EB),
      bullets: [
        'Booked consultations allow queue tracking on the consultation date once the clinic opens for operating hours.',
        'Estimated wait times adjust dynamically as doctors complete consultations or clinics pause queues.',
        'Arrive or check in promptly when your token is called to avoid automatic skip or reschedule.',
      ],
    ),
    LegalSectionItem(
      number: '03',
      title: 'Fees, Receipts & Refunds',
      summary: 'Transparent checkout and itemized digital consultation slips.',
      icon: Icons.payments_outlined,
      accent: Color(0xFF10B981),
      bullets: [
        'Consultation and queue booking fees displayed before checkout include clinic-specified charges.',
        'Eligible cancellations and clinic-initiated slot changes trigger refunds back to your original payment source.',
        'Downloadable GST-compliant receipts and refund slips remain accessible inside Payment History.',
      ],
    ),
    LegalSectionItem(
      number: '04',
      title: 'Reviews & Medical Disclaimer',
      summary: 'QueueFlow facilitates coordination, not direct medical advice.',
      icon: Icons.health_and_safety_outlined,
      accent: Color(0xFFF59E0B),
      bullets: [
        'Medical advice, diagnoses, and treatments are provided solely by independent clinics and licensed doctors.',
        'Ratings and reviews must reflect genuine clinic visits and remain respectful and factual.',
        'In life-threatening emergencies, seek immediate in-person emergency medical care rather than waiting in queue.',
      ],
    ),
  ],
);
