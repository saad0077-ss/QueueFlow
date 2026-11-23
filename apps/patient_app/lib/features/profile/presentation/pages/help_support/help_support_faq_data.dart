class HelpSupportFaqData {
  static const List<Map<String, String>> allFaqs = [
    {
      'q': 'How does live queue estimation work?',
      'a': 'QueueFlow calculates estimated waiting time using dynamic algorithmic tracking of doctor consultation pace, current waiting count ahead of you, and average procedure durations. Time updates automatically every 15 seconds.',
    },
    {
      'q': 'What should I do if my token is skipped?',
      'a': 'If your token was called while you stepped out or your number passed, use the Raise Concern tab and select "My token was skipped". The front desk receptionist will re-queue you as the next priority consult upon return.',
    },
    {
      'q': 'Can I leave the clinic and return before my turn?',
      'a': 'Yes! QueueFlow GPS radar monitors your distance. We recommend being within 5 minutes of the clinic when there are 2 patients ahead of you. You will receive SMS and push notifications when you are next.',
    },
    {
      'q': 'How do I reschedule or cancel an appointment?',
      'a': 'Go to the Bookings tab from the bottom navigation, tap your appointment card, and select "Reschedule Slot" or "Cancel Appointment". You can also raise a concern under "Appointments & Booking" for special slot requests.',
    },
    {
      'q': 'How does SLA commitment work for raised concerns?',
      'a': 'Every raised concern is assigned a response SLA (between 5 and 25 minutes depending on priority). Clinic front-desk coordinators and doctor assistants receive high-priority desktop sound pings until acknowledged.',
    },
    {
      'q': 'How can I obtain a consultation tax invoice?',
      'a': 'Paid digital consultation invoices are automatically sent to your registered email. You can also view past receipts under Profile > Payment History, or raise a concern under "Billing & Payments" to request a re-dispatch.',
    },
  ];
}
