import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class HistoryList extends StatefulWidget {
  final List<Round> rounds;

  const HistoryList({super.key, required this.rounds});

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(HistoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rounds.length > oldWidget.rounds.length) {
      // Scroll to bottom after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.trophy, size: 48, color: Colors.white.withValues(alpha:0.2)),
            const SizedBox(height: 16),
            Text(
              "La partida comienza ahora.",
              style: TextStyle(color: Colors.white.withValues(alpha:0.5), fontWeight: FontWeight.bold),
            ),
            Text(
              "¡Agrega la primera mano!",
              style: TextStyle(color: Colors.white.withValues(alpha:0.3), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF181411).withValues(alpha:0.95),
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha:0.05))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.watch<GameProvider>().nameUs.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  context.watch<GameProvider>().nameThem.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // List
        ListView.builder(
          // controller: _scrollController, // Parent handles scroll
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100), // Space for FAB
          itemCount: widget.rounds.length,
          itemBuilder: (context, index) {
            final round = widget.rounds[index];
            return GestureDetector(
              onLongPress: index == widget.rounds.length - 1 ? () => _confirmDelete(context) : null,
              // Actually rounds are usually appended. checking index logic.
              // Logic in provider: _rounds.add(newRound).
              // ListView usage: widget.rounds[index].
              // So index 0 is the OLDest round usually?
              // Let's check HistoryList usage or logic.
              // Provider adds to end.
              // ListView builder index 0 is the first item in the list passed to it.
              // If we want to delete the LAST round added, that is rounds.last.
              // If the list is displayed in reverse order (newest top), then index 0 is newest.
              // Let's check how rounds are passed or rendered. 
              // The list is just `widget.rounds`. 
              // Usually we want to show newest first? 
              // Existing code doesn't reverse it. 
              // So index 0 is the OLDest.
              // The user wants to delete if they made a mistake (usually perfectly undoing the last action).
              // So we should only allow deleting the LAST item in the list.
              // widget.rounds.length - 1.
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white12),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              round.winner == Team.us ? "+${round.points}" : "-",
                              style: TextStyle(
                                color: round.winner == Team.us ? AppColors.teamUs : Colors.white.withValues(alpha:0.1),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              round.winner == Team.them ? "+${round.points}" : "-",
                              style: TextStyle(
                                color: round.winner == Team.them ? AppColors.teamThem : Colors.white.withValues(alpha:0.1),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (index == widget.rounds.length - 1)
                      Positioned(
                        right: 8,
                        child: IconButton(
                          onPressed: () => _confirmDelete(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.5, end: 0, duration: 300.ms);
          },
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("¿Eliminar última ronda?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Se restarán los puntos y se anulará la jugada. Esto no se puede deshacer.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              context.read<GameProvider>().deleteLastRound();
              Navigator.pop(ctx);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
