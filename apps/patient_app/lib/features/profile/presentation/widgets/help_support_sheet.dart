import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/support_ticket_entity.dart';

class HelpSupportSheet extends StatefulWidget {
  final List<SupportTicketEntity> tickets;
  final String? activeTicketId;
  final ValueChanged<String> onSelectTicket;
  final void Function(String ticketId, String message) onSendReply;
  final void Function({
    required String clinicId,
    required String clinicName,
    required String category,
    required String subject,
    required String description,
  }) onRaiseTicket;

  const HelpSupportSheet({
    super.key,
    required this.tickets,
    required this.activeTicketId,
    required this.onSelectTicket,
    required this.onSendReply,
    required this.onRaiseTicket,
  });

  static Future<void> show(
    BuildContext context, {
    required List<SupportTicketEntity> tickets,
    required String? activeTicketId,
    required ValueChanged<String> onSelectTicket,
    required void Function(String ticketId, String message) onSendReply,
    required void Function({
      required String clinicId,
      required String clinicName,
      required String category,
      required String subject,
      required String description,
    }) onRaiseTicket,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HelpSupportSheet(
        tickets: tickets,
        activeTicketId: activeTicketId,
        onSelectTicket: onSelectTicket,
        onSendReply: onSendReply,
        onRaiseTicket: onRaiseTicket,
      ),
    );
  }

  @override
  State<HelpSupportSheet> createState() => _HelpSupportSheetState();
}

class _HelpSupportSheetState extends State<HelpSupportSheet> {
  int _selectedTabIndex = 0; // 0: Ticket Progress & Chat, 1: Raise New Ticket
  late TextEditingController _replyController;
  late TextEditingController _subjectController;
  late TextEditingController _descController;

  final _clinics = const [
    {'id': 'sunrise-health', 'name': 'Sunrise Health Clinic'},
    {'id': 'smile-dental', 'name': 'Smile Dental Clinic'},
    {'id': 'metro-general', 'name': 'Metro General Clinic'},
    {'id': 'apex-derma', 'name': 'Apex Dermatology Center'},
  ];

  final _categories = const [
    {'id': 'queue', 'label': 'Queue & Token Dispatch'},
    {'id': 'appointment', 'label': 'Appointment Reschedule'},
    {'id': 'billing', 'label': 'Billing & Payment Receipt'},
    {'id': 'doctor', 'label': 'Doctor Consultation Query'},
    {'id': 'technical', 'label': 'Technical / App Bug'},
  ];

  late String _selectedClinicId;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
    _subjectController = TextEditingController();
    _descController = TextEditingController();
    _selectedClinicId = _clinics.first['id']!;
    _selectedCategory = _categories.first['id']!;
  }

  @override
  void dispose() {
    _replyController.dispose();
    _subjectController.dispose();
    _descController.dispose();
    super.dispose();
  }

  SupportTicketEntity? get _currentTicket {
    if (widget.tickets.isEmpty) return null;
    if (widget.activeTicketId != null) {
      final found = widget.tickets.where((t) => t.id == widget.activeTicketId);
      if (found.isNotEmpty) return found.first;
    }
    return widget.tickets.first;
  }

  void _handleSendReply() {
    final text = _replyController.text.trim();
    final ticket = _currentTicket;
    if (text.isEmpty || ticket == null) return;
    widget.onSendReply(ticket.id, text);
    _replyController.clear();
  }

  void _handleRaiseTicket() {
    final subject = _subjectController.text.trim();
    final desc = _descController.text.trim();
    if (subject.isEmpty || desc.isEmpty) return;

    final clinicObj = _clinics.firstWhere((c) => c['id'] == _selectedClinicId);

    widget.onRaiseTicket(
      clinicId: _selectedClinicId,
      clinicName: clinicObj['name']!,
      category: _selectedCategory,
      subject: subject,
      description: desc,
    );

    _subjectController.clear();
    _descController.clear();
    setState(() => _selectedTabIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final ticket = _currentTicket;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
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
                    'Help & Support Hub',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '24/7 patient assistance & guides',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: colors.textMuted, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceSecondary,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Navigation Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 0 ? colors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: _selectedTabIndex == 0
                            ? Border.all(color: colors.border, width: 1)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '🎫 Ticket Progress & Chat',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedTabIndex == 0 ? colors.primary : colors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 1 ? colors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: _selectedTabIndex == 1
                            ? Border.all(color: colors.border, width: 1)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '＋ Raise New Ticket',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedTabIndex == 1 ? colors.primary : colors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Body Views
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildTicketProgressView(ticket)
                : _buildRaiseTicketView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketProgressView(SupportTicketEntity? ticket) {
    final colors = context.colors;

    if (ticket == null) {
      return Center(
        child: Text(
          'No tickets found. Raise a ticket above!',
          style: TextStyle(color: colors.textMuted, fontSize: 13),
        ),
      );
    }

    final isResolved = ticket.status.toLowerCase() == 'resolved';
    final isInProgress = ticket.status.toLowerCase() == 'in_progress';

    return Column(
      children: [
        // Ticket selector pills scroll
        if (widget.tickets.length > 1) ...[
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.tickets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final t = widget.tickets[i];
                final isSelected = t.id == ticket.id;
                return InkWell(
                  onTap: () => widget.onSelectTicket(t.id),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primaryTint : colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected ? colors.primary : colors.border,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#${t.id}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? colors.primary : colors.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Expanded Ticket Content with Stepper & Chat
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ticket Card Header Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Ticket #${ticket.id}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isResolved
                                      ? colors.success.withValues(alpha: 0.18)
                                      : colors.warning.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  ticket.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isResolved ? colors.success : colors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ticket.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ticket.subject,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Clinic & SLA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '🏥 ${ticket.clinicName}',
                            style: TextStyle(fontSize: 11.5, color: colors.textMuted),
                          ),
                          Text(
                            ticket.slaNotice,
                            style: TextStyle(fontSize: 11, color: colors.textSubtle),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 3-Stage Progress Stepper
                      _buildStepper(isResolved: isResolved, isInProgress: isInProgress),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Conversation Transcript
                Text(
                  'CONVERSATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSubtle,
                  ),
                ),
                const SizedBox(height: 8),

                // Messages list
                ...ticket.messages.map((m) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: m.isUser
                              ? colors.primary
                              : colors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(14),
                          border: m.isUser
                              ? null
                              : Border.all(color: colors.border, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              m.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!m.isUser) ...[
                              Text(
                                m.sender,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: colors.accent,
                                ),
                              ),
                              const SizedBox(height: 3),
                            ],
                            Text(
                              m.text,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: m.isUser ? Colors.white : colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              m.time,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: m.isUser
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : colors.textSubtle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Quick Reply Bar
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border, width: 1.5),
                ),
                child: TextField(
                  controller: _replyController,
                  style: TextStyle(fontSize: 13, color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Type reply to clinic desk...',
                    hintStyle: TextStyle(color: colors.textSubtle, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) => _handleSendReply(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _handleSendReply,
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: colors.primary,
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepper({required bool isResolved, required bool isInProgress}) {
    return Row(
      children: [
        // Step 1: Submitted
        _buildStepNode(
          label: '1. Submitted',
          isDone: true,
          isActive: false,
        ),
        _buildConnector(isDone: isInProgress || isResolved),

        // Step 2: Under Review
        _buildStepNode(
          label: '2. Under Review',
          isDone: isResolved,
          isActive: isInProgress,
        ),
        _buildConnector(isDone: isResolved),

        // Step 3: Resolved
        _buildStepNode(
          label: '3. Resolved',
          isDone: isResolved,
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildStepNode({
    required String label,
    required bool isDone,
    required bool isActive,
  }) {
    final colors = context.colors;

    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? colors.success
                : (isActive ? colors.warning : colors.surface),
            border: Border.all(
              color: isDone
                  ? colors.success
                  : (isActive ? colors.warning : colors.border),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check, size: 13, color: Colors.white)
              : (isActive
                  ? Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                  : const SizedBox.shrink()),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDone || isActive ? colors.textPrimary : colors.textSubtle,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required bool isDone}) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isDone ? colors.success : colors.border,
      ),
    );
  }

  Widget _buildRaiseTicketView() {
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Raise a Support Ticket',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Directly alert the clinic coordination team and receive SLA-backed resolution.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Clinic selector
          Text(
            'Clinic',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedClinicId,
                dropdownColor: colors.surfaceElevated,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted),
                style: TextStyle(fontSize: 13, color: colors.textPrimary, fontWeight: FontWeight.w600),
                items: _clinics.map((c) {
                  return DropdownMenuItem<String>(
                    value: c['id'],
                    child: Text(c['name']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedClinicId = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category
          Text(
            'Issue Category',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                dropdownColor: colors.surfaceElevated,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted),
                style: TextStyle(fontSize: 13, color: colors.textPrimary, fontWeight: FontWeight.w600),
                items: _categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['id'],
                    child: Text(cat['label']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Subject
          Text(
            'Subject',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border, width: 1.5),
            ),
            child: TextField(
              controller: _subjectController,
              style: TextStyle(fontSize: 13, color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Need assistance with token dispatch',
                hintStyle: TextStyle(color: colors.textSubtle, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Detailed description
          Text(
            'Detailed Description',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border, width: 1.5),
            ),
            child: TextField(
              controller: _descController,
              maxLines: 4,
              style: TextStyle(fontSize: 13, color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Explain the details of your inquiry or issue...',
                hintStyle: TextStyle(color: colors.textSubtle, fontSize: 12.5),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Submit Button
          ElevatedButton(
            onPressed: _handleRaiseTicket,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: const Text(
              'Submit Support Ticket',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
