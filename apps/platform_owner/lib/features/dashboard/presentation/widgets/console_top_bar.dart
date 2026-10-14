import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConsoleTopBar extends StatelessWidget {
  final ValueChanged<String>? onSearch;
  final VoidCallback? onMenuPressed;

  const ConsoleTopBar({super.key, this.onSearch, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 620;
        return Container(
          height: 64,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
          decoration: const BoxDecoration(
            color: Color(0xFF070B14),
            border: Border(bottom: BorderSide(color: Color(0xFF131D31), width: 1)),
          ),
          child: Row(
            children: [
              if (onMenuPressed != null) ...[
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                  onPressed: onMenuPressed,
                  tooltip: 'Open navigation',
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Container(
                  height: 40,
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: TextField(
                    onChanged: onSearch,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: isMobile ? 'Search...' : 'Search patients, appointments...',
                      hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF94A3B8), size: 20),
                onPressed: () {},
              ),
              const SizedBox(width: 6),
              const CircleAvatar(
                radius: 15,
                backgroundColor: Color(0xFF0284C7),
                child: Text('MS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Muhammed Saad', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text('Platform Admin', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
