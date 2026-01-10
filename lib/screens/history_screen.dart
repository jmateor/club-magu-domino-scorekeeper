import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<GameProvider>().savedGames;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha:0.5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Historial de Partidas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.calendar, size: 48, color: Colors.white.withValues(alpha:0.2)),
                  const SizedBox(height: 16),
                  Text("No hay partidas guardadas.", style: TextStyle(color: Colors.white.withValues(alpha:0.3))),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final game = history[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha:0.05)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha:0.2), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.calendar, size: 14, color: Colors.white38),
                              const SizedBox(width: 4),
                              Text(game.date, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: game.winner == Team.us ? AppColors.teamUs.withValues(alpha:0.2) : AppColors.teamThem.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              game.winner == Team.us ? "Ganaron ${game.nameUs}" : "Ganaron ${game.nameThem}",
                              style: TextStyle(
                                color: game.winner == Team.us ? AppColors.teamUs : AppColors.teamThem,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTeamScore(Team.us, game.winner == Team.us, game.nameUs),
                              const SizedBox(height: 8),
                              _buildTeamScore(Team.them, game.winner == Team.them, game.nameThem),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 24),
                            decoration: BoxDecoration(
                              border: Border(left: BorderSide(color: Colors.white.withValues(alpha:0.1))),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${game.scoreUs}', style: TextStyle(color: game.winner == Team.us ? AppColors.teamUs : Colors.white38, fontSize: 24, fontWeight: FontWeight.w900)),
                                Text('${game.scoreThem}', style: TextStyle(color: game.winner == Team.them ? AppColors.teamThem : Colors.white38, fontSize: 24, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTeamScore(Team team, bool isWinner, String name) {
    final color = team == Team.us ? AppColors.teamUs : AppColors.teamThem;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isWinner ? color.withValues(alpha:0.2) : Colors.white.withValues(alpha:0.05),
            shape: BoxShape.circle,
          ),
          child: isWinner ? Icon(LucideIcons.trophy, size: 16, color: color) : null,
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: TextStyle(
            color: isWinner ? Colors.white : Colors.white.withValues(alpha:0.5),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
