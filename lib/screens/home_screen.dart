import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/history_list.dart';
import '../widgets/add_round_sheet.dart';
import '../widgets/win_dialog.dart';
import '../widgets/app_drawer.dart';
import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Check for winner on every build and show dialog if needed
  void _checkForWinner(GameProvider game) {
    if (game.winner != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.isCurrent == true) {
           showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => WinDialog(winner: game.winner!),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    _checkForWinner(game);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Background Ambience
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 0.8,
                  colors: [
                    Color(0x4D181411), // Adjust opacity manually
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("CLUB MAGÚ", style: TextStyle(color: Colors.white.withValues(alpha:0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                  const Text("Puntuación", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                ],
                               ),
                               Builder(
                                 builder: (context) => IconButton(
                                   icon: Container(
                                     padding: const EdgeInsets.all(8),
                                     decoration: BoxDecoration(
                                       color: AppColors.surface,
                                       borderRadius: BorderRadius.circular(12),
                                       border: Border.all(color: Colors.white.withValues(alpha:0.05)),
                                     ),
                                     child: const Icon(LucideIcons.menu, color: Colors.white70, size: 20),
                                   ),
                                   onPressed: () => Scaffold.of(context).openDrawer(),
                                 ),
                               ),
                            ],
                          ),
                        ),

                        // Motivational Banner
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              game.commentary,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.primary.withValues(alpha:0.8), fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),

                        // Score Cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(child: _buildScoreCard(game.scoreUs, Team.us)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildScoreCard(game.scoreThem, Team.them)),
                            ],
                          ),
                        ),

                        // Progress Bar (Fixed: Single instance)
                        Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                           child: Column(
                             children: [
                                Container(
                                  height: 6,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha:0.05),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Stack(
                                    children: [
                                      AnimatedFractionallySizedBox(
                                        duration: 500.ms,
                                        widthFactor: (game.scoreUs / winningScore).clamp(0.0, 1.0),
                                        alignment: Alignment.centerLeft,
                                        child: Container(color: AppColors.teamUs),
                                      ),
                                      AnimatedFractionallySizedBox(
                                        duration: 500.ms,
                                        widthFactor: (game.scoreThem / winningScore).clamp(0.0, 1.0),
                                        alignment: Alignment.centerRight,
                                        child: Container(color: AppColors.teamThem),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("0", style: TextStyle(color: Colors.white.withValues(alpha:0.3), fontSize: 10, fontWeight: FontWeight.bold)),
                                    Text("Objetivo: $winningScore", style: TextStyle(color: Colors.white.withValues(alpha:0.3), fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                             ],
                           ),
                        ),
                      ],
                    ),
                  ),
                ),

                // History List Container
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha:0.5),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      border: Border(top: BorderSide(color: Colors.white.withValues(alpha:0.05))),
                      boxShadow: [
                         BoxShadow(color: Colors.black.withValues(alpha:0.5), blurRadius: 40, offset: const Offset(0, -10)),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: HistoryList(rounds: game.rounds),
                  ),
                ),
              ],
            ),
          ),
          
          // FAB
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                   showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // Needed for full height
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AddRoundSheet(),
                  );
                },
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha:0.4), blurRadius: 25, spreadRadius: 0),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("AGREGAR RONDA", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      SizedBox(width: 12),
                      Icon(LucideIcons.plus, color: Colors.white, size: 24),
                    ],
                  ),
                ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
              ),
            ),
          ),

          // Notification Toast
          if (game.notificationMessage != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: _buildNotification(game.notificationMessage!, game.notificationType!, context),
            ).animate().slideY(begin: 1.0, end: 0, duration: 400.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildScoreCard(int score, Team team) {
    final isUs = team == Team.us;
    final color = isUs ? AppColors.teamUs : AppColors.teamThem;
    final gradientColors = isUs 
      ? [const Color(0xFF064E3B), AppColors.surface] 
      : [const Color(0xFF7C2D12), AppColors.surface];

    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha:0.3)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha:0.15), blurRadius: 20),
        ],
      ),
      child: Stack(
        children: [
          // Glow effect (simplified)
          Positioned(
            top: -20,
            right: isUs ? -20 : null,
            left: !isUs ? -20 : null,
            child: Container(width: 80, height: 80, decoration: BoxDecoration(color: color.withValues(alpha:0.2), borderRadius: BorderRadius.circular(100))),
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isUs) ...[
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 8)])),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    isUs ? context.read<GameProvider>().nameUs.toUpperCase() : context.read<GameProvider>().nameThem.toUpperCase(),
                    style: TextStyle(color: isUs ? color : AppColors.teamThem, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  if (!isUs) ...[
                    const SizedBox(width: 8),
                     Container(width: 8, height: 8, decoration: BoxDecoration(color: color.withValues(alpha:0.5), shape: BoxShape.circle)),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "$score",
                style: TextStyle(
                  color: !isUs ? Colors.white.withValues(alpha:0.9) : Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotification(String message, String type, BuildContext context) {
    final isFire = type == 'fire';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF1E3A8A)]), // Indigo to Blue
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha:0.1)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isFire ? Colors.orange.withValues(alpha:0.2) : Colors.blue.withValues(alpha:0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(isFire ? LucideIcons.flame : LucideIcons.frown, color: isFire ? Colors.orange : Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("ESTADO DEL JUEGO", style: TextStyle(color: Colors.white.withValues(alpha:0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.checkCircle, color: Colors.white.withValues(alpha:0.3)),
            onPressed: () => context.read<GameProvider>().clearNotification(),
          ),
        ],
      ),
    );
  }
}
