import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/platform_user_entity.dart';

class PlatformUsersDataTable extends StatelessWidget {
  final List<PlatformUserEntity> users;
  final ValueChanged<PlatformUserEntity> onDeleteUser;

  const PlatformUsersDataTable({
    super.key,
    required this.users,
    required this.onDeleteUser,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (users.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline_rounded, color: colors.textMuted, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              'No registered patients found',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No users matched your current search and filter criteria.',
              style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 950),
            child: DataTable(
              headingRowHeight: 46,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 64,
              horizontalMargin: 20,
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(colors.surfaceSecondary),
              columns: [
                DataColumn(
                  label: Text('Patient / User', style: _headerStyle(colors)),
                ),
                DataColumn(
                  label: Text('Contact Info', style: _headerStyle(colors)),
                ),
                DataColumn(
                  label: Text('Primary Clinic', style: _headerStyle(colors)),
                ),
                DataColumn(
                  label: Text('Live Queue Token', style: _headerStyle(colors)),
                ),
                DataColumn(
                  label: Text('Member Since', style: _headerStyle(colors)),
                ),
                DataColumn(
                  label: Text('Activity', style: _headerStyle(colors)),
                ),
                DataColumn(
                  label: Text('Status', style: _headerStyle(colors)),
                ),
                DataColumn(
                  numeric: true,
                  label: Text('Actions', style: _headerStyle(colors)),
                ),
              ],
              rows: users.map((u) => _buildRow(context, colors, u)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _headerStyle(AppColorsExtension colors) {
    return GoogleFonts.inter(
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      color: colors.textMuted,
      letterSpacing: 0.2,
    );
  }

  DataRow _buildRow(BuildContext context, AppColorsExtension colors, PlatformUserEntity u) {
    return DataRow(
      cells: [
        // 1. Patient / User
        DataCell(
          Row(
            children: [
              _buildAvatar(colors, u),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.name,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    u.healthId,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Contact Info
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                u.email.isNotEmpty ? u.email : 'No email',
                style: GoogleFonts.inter(fontSize: 12.5, color: colors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                u.phone.isNotEmpty ? u.phone : 'No phone',
                style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
              ),
            ],
          ),
        ),

        // 3. Primary Clinic
        DataCell(
          Text(
            u.homeClinicName,
            style: GoogleFonts.inter(fontSize: 12.5, color: colors.textPrimary),
          ),
        ),

        // 4. Live Queue Token
        DataCell(
          _buildTokenBadge(colors, u),
        ),

        // 5. Member Since
        DataCell(
          Text(
            u.memberSince,
            style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
          ),
        ),

        // 6. Activity
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              '${u.totalBookings} visits',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textPrimary),
            ),
          ),
        ),

        // 7. Status
        DataCell(
          _buildStatusBadge(colors, u),
        ),

        // 8. Actions
        DataCell(
          IconButton(
            tooltip: 'Purge Patient Records',
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
            onPressed: () => onDeleteUser(u),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(AppColorsExtension colors, PlatformUserEntity u) {
    if (u.photoBase64 != null && u.photoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(u.photoBase64!);
        return CircleAvatar(
          radius: 17,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {}
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF0072FF).withAlpha(25),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF0072FF).withAlpha(60)),
      ),
      alignment: Alignment.center,
      child: Text(
        u.initials.isNotEmpty ? u.initials : 'U',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0072FF),
        ),
      ),
    );
  }

  Widget _buildTokenBadge(AppColorsExtension colors, PlatformUserEntity u) {
    if (u.activeQueueToken == null || u.activeQueueToken!.isEmpty) {
      return Text('—', style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted));
    }

    final isCalled = u.activeQueueStatus == 'called';
    final color = isCalled ? const Color(0xFF0072FF) : const Color(0xFFF59E0B);
    final statusLabel = isCalled ? 'Called' : 'Waiting';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(
            '${u.activeQueueToken!} ($statusLabel)',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AppColorsExtension colors, PlatformUserEntity u) {
    Color badgeColor;
    String label;

    if (u.activeQueueToken != null && u.activeQueueToken!.isNotEmpty) {
      badgeColor = const Color(0xFFF59E0B);
      label = 'IN QUEUE';
    } else if (u.isVerified) {
      badgeColor = const Color(0xFF10B981);
      label = 'VERIFIED';
    } else {
      badgeColor = const Color(0xFF6B7280);
      label = 'ACTIVE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withAlpha(50)),
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
