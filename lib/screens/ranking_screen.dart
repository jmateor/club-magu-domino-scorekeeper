import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../models/models.dart';

class RankingsScreen extends StatelessWidget {
  const RankingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    final history = game.savedGames;

    // Simple stats calculation
    int winsUs = history.where((g) => g.winner == Team.us).length;
    int winsThem = history.where((g) => g.winner == Team.them).length;
    
    // Determine "Leader" (Fastest Win)
    SavedGame? fastestGame;
    int minSeconds = 999999;

    for (var g in history) {
      // Parse duration "M:SS min"
      try {
        final parts = g.durationFormatted.replaceAll(' min', '').split(':');
        if (parts.length == 2) {
          final seconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
          if (seconds < minSeconds) {
             minSeconds = seconds;
             fastestGame = g;
          }
        }
      } catch (e) {
        // ignore parsing error
      }
    }

    String leaderName = fastestGame != null 
        ? (fastestGame.winner == Team.us ? fastestGame.nameUs : fastestGame.nameThem)
        : "N/A";
    
    String leaderStats = fastestGame != null ? "Récord: ${fastestGame.durationFormatted}" : "Sin partidas";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Rankings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withValues(alpha:0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(LucideIcons.crown, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    const Text("Campeón (Más Rápido)", style: TextStyle(color: Colors.white70, letterSpacing: 1.2)),
                    Text(leaderName, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    Text(leaderStats, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              
              // Stats List
              _buildRankItem("1", "Nosotros", "$winsUs", true),
              const SizedBox(height: 12),
              _buildRankItem("2", "Ellos", "$winsThem", false),
              
              const SizedBox(height: 12),
              // Placeholder for more generic rankings if we had individual players
              _buildRankItem("3", "Invitado", "0", false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankItem(String rank, String name, String score, bool isTop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isTop ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Text(rank, style: TextStyle(color: isTop ? AppColors.primary : Colors.white54, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 24),
          Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          Text("$score Wins", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
