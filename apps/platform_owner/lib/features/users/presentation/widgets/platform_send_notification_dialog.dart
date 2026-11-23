import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_user_entity.dart';

class PlatformSendNotificationDialog extends StatefulWidget {
  final PlatformUserEntity? targetUser; // null means broadcast to all users
  final int totalUsersCount;
  final Future<void> Function({
    required String targetUserId,
    required String title,
    required String message,
    String? targetEmail,
    String? type,
  })
  onSend;

  const PlatformSendNotificationDialog({
    super.key,
    this.targetUser,
    required this.totalUsersCount,
    required this.onSend,
  });

  @override
  State<PlatformSendNotificationDialog> createState() =>
      _PlatformSendNotificationDialogState();
}

class _PlatformSendNotificationDialogState
    extends State<PlatformSendNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String _notificationType = 'general';
  bool _isSending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      final isBroadcast = widget.targetUser == null;
      await widget.onSend(
        targetUserId: isBroadcast ? 'all' : widget.targetUser!.id,
        targetEmail: widget.targetUser?.email,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: _notificationType,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
          _errorMessage = 'Failed to send notification: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isBroadcast = widget.targetUser == null;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              (isBroadcast
                                      ? const Color(0xFF0072FF)
                                      : const Color(0xFF10B981))
                                  .withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isBroadcast
                              ? Icons.campaign_rounded
                              : Icons.notifications_active_rounded,
                          color: isBroadcast
                              ? const Color(0xFF0072FF)
                              : const Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isBroadcast
                            ? 'Broadcast Notification'
                            : 'Send Push Notification',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.border),

            // Form
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withAlpha(60),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Recipient Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_pin_rounded,
                            color: const Color(0xFF0072FF),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RECIPIENT',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isBroadcast
                                      ? 'All Registered Mobile Users (${widget.totalUsersCount} recipients)'
                                      : '${widget.targetUser!.name} (${widget.targetUser!.phone.isNotEmpty ? widget.targetUser!.phone : widget.targetUser!.email})',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notification Type Selector
                    Text(
                      'Notification Category',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _notificationType,
                          isExpanded: true,
                          dropdownColor: colors.surface,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: colors.textPrimary,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'general',
                              child: Text('📢 General Announcement'),
                            ),
                            DropdownMenuItem(
                              value: 'queue',
                              child: Text('🎟️ Queue Status Alert'),
                            ),
                            DropdownMenuItem(
                              value: 'maintenance',
                              child: Text('🛠️ System Maintenance'),
                            ),
                            DropdownMenuItem(
                              value: 'emergency',
                              child: Text('⚠️ Urgent / Critical Alert'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _notificationType = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title
                    Text(
                      'Subject / Title *',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Title is required'
                          : null,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'e.g. Schedule Update or Queue Announcement',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: colors.textMuted,
                        ),
                        filled: true,
                        fillColor: colors.surfaceSecondary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF0072FF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Message Body
                    Text(
                      'Notification Message *',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Message is required'
                          : null,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write the message to be delivered to patient mobile devices...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: colors.textMuted,
                        ),
                        filled: true,
                        fillColor: colors.surfaceSecondary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF0072FF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Divider(height: 1, color: colors.border),
            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSending
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textMuted,
                        side: BorderSide(color: colors.border),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _handleSubmit,
                      icon: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 16),
                      label: Text(
                        isBroadcast ? 'Broadcast Now' : 'Send Notification',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0072FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
