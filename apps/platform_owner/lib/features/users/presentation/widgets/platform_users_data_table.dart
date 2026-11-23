import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_user_entity.dart';

class PlatformUsersDataTable extends StatelessWidget {
  final List<PlatformUserEntity> users;
  final ValueChanged<PlatformUserEntity> onViewUser;
  final ValueChanged<PlatformUserEntity> onSendNotification;
  final ValueChanged<PlatformUserEntity> onToggleStatus;
  final ValueChanged<PlatformUserEntity> onDeleteUser;

  const PlatformUsersDataTable({
    super.key,
    required this.users,
    required this.onViewUser,
    required this.onSendNotification,
    required this.onToggleStatus,
    required this.onDeleteUser,
  });

  static const List<List<Color>> _avatarGradients = [
    [Color(0xFF2563EB), Color(0xFF38BDF8)],
    [Color(0xFF7C3AED), Color(0xFFC084FC)],
    [Color(0xFF059669), Color(0xFF34D399)],
    [Color(0xFFD97706), Color(0xFFFBBF24)],
    [Color(0xFFDC2626), Color(0xFFF87171)],
    [Color(0xFF0D9488), Color(0xFF2DD4BF)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (users.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 54, horizontal: 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                color: colors.textMuted,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No registered patients found',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No users matched your current search or filter criteria.',
              style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth > 1180
            ? constraints.maxWidth
            : 1180.0;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _buildHeader(colors),
                  for (var i = 0; i < users.length; i++)
                    _UserRowItem(
                      user: users[i],
                      gradient: _avatarGradients[i % _avatarGradients.length],
                      isLast: i == users.length - 1,
                      onViewUser: onViewUser,
                      onSendNotification: onSendNotification,
                      onToggleStatus: onToggleStatus,
                      onDeleteUser: onDeleteUser,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppColorsExtension colors) {
    final headerStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: colors.textMuted,
      letterSpacing: 0.4,
    );

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(flex: 23, child: Text('PATIENT / USER', style: headerStyle)),
          Expanded(flex: 18, child: Text('CONTACT INFO', style: headerStyle)),
          Expanded(
            flex: 15,
            child: Text('LIVE QUEUE TOKEN', style: headerStyle),
          ),
          Expanded(flex: 17, child: Text('MEMBER SINCE', style: headerStyle)),
          Expanded(flex: 16, child: Text('ACTIVITY', style: headerStyle)),
          Expanded(flex: 11, child: Text('STATUS', style: headerStyle)),
          Expanded(
            flex: 16,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('ACTIONS', style: headerStyle),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserRowItem extends StatefulWidget {
  final PlatformUserEntity user;
  final List<Color> gradient;
  final bool isLast;
  final ValueChanged<PlatformUserEntity> onViewUser;
  final ValueChanged<PlatformUserEntity> onSendNotification;
  final ValueChanged<PlatformUserEntity> onToggleStatus;
  final ValueChanged<PlatformUserEntity> onDeleteUser;

  const _UserRowItem({
    required this.user,
    required this.gradient,
    required this.isLast,
    required this.onViewUser,
    required this.onSendNotification,
    required this.onToggleStatus,
    required this.onDeleteUser,
  });

  @override
  State<_UserRowItem> createState() => _UserRowItemState();
}

class _UserRowItemState extends State<_UserRowItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final u = widget.user;
    final isSuspended = u.status.toLowerCase() == 'suspended';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: () => widget.onViewUser(u),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered ? colors.surfaceSecondary : Colors.transparent,
            border: widget.isLast
                ? null
                : Border(
                    bottom: BorderSide(color: colors.border.withAlpha(80)),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Patient / User (flex: 23)
              Expanded(
                flex: 23,
                child: Row(
                  children: [
                    _buildAvatar(colors, u, widget.gradient),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  u.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (u.isVerified) ...[
                                const SizedBox(width: 5),
                                Container(
                                  width: 15,
                                  height: 15,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0072FF),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.check,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Wrap(
                            spacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Text(
                                  u.healthId,
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textMuted,
                                  ),
                                ),
                              ),
                              if (u.age != null && u.age!.isNotEmpty)
                                Text(
                                  '• ${u.age}y',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: colors.textMuted,
                                  ),
                                ),
                              if (u.gender != null && u.gender!.isNotEmpty)
                                Text(
                                  '• ${u.gender![0].toUpperCase()}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: colors.textMuted,
                                  ),
                                ),
                              if (u.bloodGroup != null &&
                                  u.bloodGroup!.isNotEmpty)
                                Text(
                                  u.bloodGroup!,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Contact Info (flex: 18)
              Expanded(
                flex: 18,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.phone.isNotEmpty ? u.phone : 'No phone',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      u.email.isNotEmpty ? u.email : 'No email',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: colors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 3. Live Queue Token (flex: 15)
              Expanded(
                flex: 15,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildTokenCell(colors, u),
                ),
              ),

              // 4. Member Since (flex: 17)
              Expanded(
                flex: 17,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.memberSince,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: u.isWalkIn
                            ? const Color(0xFFF59E0B).withAlpha(22)
                            : const Color(0xFF0072FF).withAlpha(22),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: u.isWalkIn
                              ? const Color(0xFFF59E0B).withAlpha(60)
                              : const Color(0xFF0072FF).withAlpha(60),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        u.isWalkIn ? 'Walk-In Patient' : 'Platform User',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: u.isWalkIn
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF0072FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Activity (flex: 16)
              Expanded(
                flex: 16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${u.totalBookings}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0072FF),
                            ),
                          ),
                          TextSpan(
                            text: ' Appts • ',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: colors.textMuted,
                            ),
                          ),
                          TextSpan(
                            text: '${u.totalQueues}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          TextSpan(
                            text: ' Queues',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Active: ${u.lastActive ?? 'Today'}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 6. Status (flex: 11)
              Expanded(
                flex: 11,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildStatusBadge(colors, u, isSuspended),
                ),
              ),

              // 7. Actions (flex: 16)
              Expanded(
                flex: 16,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionBtn(
                        tooltip: 'View Details',
                        icon: Icons.visibility_outlined,
                        color: colors.textPrimary,
                        bgColor: colors.surfaceSecondary,
                        borderColor: colors.border,
                        onTap: () => widget.onViewUser(u),
                      ),
                      const SizedBox(width: 6),
                      _buildActionBtn(
                        tooltip: 'Send Notification',
                        icon: Icons.campaign_outlined,
                        color: const Color(0xFF0072FF),
                        bgColor: const Color(0xFF0072FF).withAlpha(22),
                        borderColor: const Color(0xFF0072FF).withAlpha(60),
                        onTap: () => widget.onSendNotification(u),
                      ),
                      const SizedBox(width: 6),
                      _buildActionBtn(
                        tooltip: isSuspended
                            ? 'Reactivate Account'
                            : 'Suspend Account',
                        icon: isSuspended
                            ? Icons.lock_open_rounded
                            : Icons.lock_outline_rounded,
                        color: isSuspended
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        bgColor:
                            (isSuspended
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B))
                                .withAlpha(22),
                        borderColor:
                            (isSuspended
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B))
                                .withAlpha(60),
                        onTap: () => widget.onToggleStatus(u),
                      ),
                      const SizedBox(width: 6),
                      _buildActionBtn(
                        tooltip: 'Delete User & Data',
                        icon: Icons.delete_outline_rounded,
                        color: const Color(0xFFEF4444),
                        bgColor: const Color(0xFFEF4444).withAlpha(22),
                        borderColor: const Color(0xFFEF4444).withAlpha(60),
                        onTap: () => widget.onDeleteUser(u),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required String tooltip,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: color.withAlpha(35),
          splashColor: color.withAlpha(50),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(
    AppColorsExtension colors,
    PlatformUserEntity u,
    List<Color> grad,
  ) {
    if (u.photoBase64 != null && u.photoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(u.photoBase64!);
        return CircleAvatar(radius: 18, backgroundImage: MemoryImage(bytes));
      } catch (_) {}
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: grad,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: grad.first.withAlpha(50),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        u.initials.isNotEmpty ? u.initials : 'U',
        style: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTokenCell(AppColorsExtension colors, PlatformUserEntity u) {
    if (u.activeQueueToken == null || u.activeQueueToken!.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: colors.textMuted.withAlpha(120),
              shape: BoxShape.circle,
            ),
          ),
          Text(
            'No active queue',
            style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
          ),
        ],
      );
    }

    final isCalled = u.activeQueueStatus?.toLowerCase() == 'called';
    final color = isCalled ? const Color(0xFF10B981) : const Color(0xFF0072FF);
    final statusLabel = isCalled ? 'CALLED' : 'WAITING';
    final clinicShort =
        (u.homeClinicName.isNotEmpty && u.homeClinicName != 'Unassigned')
        ? ' • ${u.homeClinicName.split(' ').first}'
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withAlpha(160), blurRadius: 6),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                u.activeQueueToken!,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                '$statusLabel$clinicShort',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    AppColorsExtension colors,
    PlatformUserEntity u,
    bool isSuspended,
  ) {
    Color badgeColor;
    String label;

    if (isSuspended) {
      badgeColor = const Color(0xFFEF4444);
      label = 'SUSPENDED';
    } else if (u.activeQueueToken != null && u.activeQueueToken!.isNotEmpty) {
      badgeColor = const Color(0xFFF59E0B);
      label = 'IN QUEUE';
    } else if (u.isVerified) {
      badgeColor = const Color(0xFF10B981);
      label = 'VERIFIED';
    } else {
      badgeColor = const Color(0xFF0072FF);
      label = 'ACTIVE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withAlpha(60)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: badgeColor,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
