import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../auth/presentation/pages/platform_admin_login_screen.dart';

class ConsoleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ConsoleAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F172A),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/icons/app_icon_128.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'QueueFlow',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: const Text(
              '👑 Platform Owner Console',
              style: TextStyle(fontSize: 12, color: Color(0xFF38BDF8)),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade900.withValues(alpha: 0.3),
            border: Border.all(color: Colors.green.shade700),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.cloud_done_rounded,
                color: Colors.greenAccent,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Connected: queueflow-db2e1',
                style: TextStyle(fontSize: 12, color: Colors.greenAccent),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.logout_rounded,
            color: Colors.white70,
            size: 20,
          ),
          tooltip: 'Sign Out Administrator',
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const PlatformAdminLoginScreen(),
                ),
              );
            }
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}
