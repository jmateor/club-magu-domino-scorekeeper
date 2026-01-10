import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';
import 'start_game_dialog.dart';
import '../screens/history_screen.dart';
import '../screens/ranking_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});



  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.crown, color: AppColors.primary, size: 40),
                const SizedBox(height: 16),
                const Text(
                  "CLUB MAGÚ",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                Text(
                  "Scorekeeper",
                  style: TextStyle(color: Colors.white.withValues(alpha:0.5), fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.rotateCcw, color: Colors.white70),
                  title: const Text('Nueva Partida', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    showDialog(
                      context: context,
                      builder: (context) => const StartGameDialog(isReset: true),
                    );
                  },
                ),
                const Divider(color: Colors.white12, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(LucideIcons.history, color: Colors.white70),
                  title: const Text('Historial', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.barChart2, color: Colors.white70),
                  title: const Text('Rankings', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RankingsScreen()));
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "v1.0.0",
              style: TextStyle(color: Colors.white.withValues(alpha:0.2), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
