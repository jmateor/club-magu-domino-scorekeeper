import 'package:flutter/material.dart';
import 'ranking_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../providers/game_provider.dart';
import 'history_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/start_game_dialog.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Read stats from provider
    final game = context.watch<GameProvider>();
    final totalGames = game.savedGames.length;

    const championName = "Nosotros"; 

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(), // Added Drawer
      body: Stack(
        children: [
          // Background Gradient Ambience
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.8,
                  colors: [
                    AppColors.primary.withValues(alpha:0.15),
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
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Builder(
                                builder: (context) => IconButton(
                                  icon: const Icon(LucideIcons.menu, color: Colors.white, size: 24),
                                  onPressed: () => Scaffold.of(context).openDrawer(),
                                ),
                              ),
                              Text("Magú", style: TextStyle(color: Colors.white, fontFamily: GoogleFonts.outfit().fontFamily, fontWeight: FontWeight.bold, fontSize: 18)),
                              const Icon(LucideIcons.settings, color: Colors.white, size: 24),
                            ],
                          ),
                        ),

                        // Hero Section
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Circle Logo
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1E293B), // Dark slate
                                  border: Border.all(color: AppColors.primary.withValues(alpha:0.5), width: 2),
                                  boxShadow: [
                                    BoxShadow(color: AppColors.primary.withValues(alpha:0.2), blurRadius: 40, spreadRadius: 5),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(LucideIcons.dice5, size: 60, color: Colors.white.withValues(alpha:0.8)),
                                ),
                              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                              
                              const SizedBox(height: 32),
                              
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                                  children: const [
                                    TextSpan(text: "Club de Dominó "),
                                    TextSpan(text: "Magú", style: TextStyle(color: AppColors.primary)),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              const Text(
                                "Tu compañero de juego profesional.\nAnota, analiza y gana.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white54, fontSize: 16, height: 1.5),
                              ),

                              const SizedBox(height: 40),

                              // Stats Grid
                              Row(
                                children: [
                                  Expanded(child: _buildStatCard(LucideIcons.dice5, "$totalGames", "PARTIDAS")),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildStatCard(LucideIcons.trophy, championName, "CAMPEÓN")),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),

                        // Actions
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                   showDialog(
                                     context: context,
                                     builder: (context) => const StartGameDialog(isReset: false),
                                   );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 4,
                                  shadowColor: AppColors.primary.withValues(alpha:0.4),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow_rounded, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Iniciar Nueva Partida", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Rankings Button (Active now)
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RankingsScreen())),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  backgroundColor: Colors.white.withValues(alpha:0.05),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.barChart2, color: Colors.white70, size: 20),
                                    SizedBox(width: 8),
                                    Text("Ver Rankings", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  backgroundColor: Colors.white.withValues(alpha:0.05),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.history, color: Colors.white70, size: 20),
                                    SizedBox(width: 8),
                                    Text("Ver Historial", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        // Bottom Nav Placeholder (Visual only as per design)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                             _buildNavItem(LucideIcons.home, "Inicio", true),
                             _buildNavItem(LucideIcons.barChart2, "Rankings", false),
                             _buildNavItem(LucideIcons.users, "Club", false),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha:0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Icon(icon, color: isActive ? AppColors.primary : Colors.white38, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isActive ? AppColors.primary : Colors.white38, fontSize: 10)),
      ],
    );
  }

}
