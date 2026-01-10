import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import 'start_game_dialog.dart';

class WinDialog extends StatelessWidget {
  final Team winner;

  const WinDialog({super.key, required this.winner});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha:0.1)),
          boxShadow: [
             BoxShadow(
              color: AppColors.primary.withValues(alpha:0.2),
              blurRadius: 40,
              spreadRadius: 5,
             ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary,
                    blurRadius: 20,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: const Icon(LucideIcons.trophy, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              "¡${winner == Team.us ? context.read<GameProvider>().nameUs.toUpperCase() : context.read<GameProvider>().nameThem.toUpperCase()} GANAN!",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "La partida ha finalizado. Los puntos se han guardado en el historial.",
              style: TextStyle(color: Colors.white.withValues(alpha:0.5), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => const StartGameDialog(isReset: true),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.rotateCcw, size: 20),
                    SizedBox(width: 8),
                    Text("NUEVA PARTIDA", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
