import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import 'keypad.dart';

class AddRoundSheet extends StatefulWidget {
  const AddRoundSheet({super.key});

  @override
  State<AddRoundSheet> createState() => _AddRoundSheetState();
}

class _AddRoundSheetState extends State<AddRoundSheet> {
  Team _selectedWinner = Team.us;
  String _points = "";

  void _handleKeyPress(String k) {
    if (_points.length < 3) {
      setState(() => _points += k);
    }
  }

  void _handleDelete() {
    if (_points.isNotEmpty) {
      setState(() => _points = _points.substring(0, _points.length - 1));
    }
  }

  void _handleClear() {
    setState(() => _points = "");
  }

  void _handleConfirm() {
    final points = int.tryParse(_points);
    if (points != null && points > 0) {
      context.read<GameProvider>().addRound(points, _selectedWinner);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85, // Taller to allow more space
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 48, height: 6, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(3))),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const Text("Agregar Ronda", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("¿Quién ganó esta mano?", style: TextStyle(color: Colors.white.withValues(alpha:0.4), fontSize: 14)),
                      const SizedBox(height: 24),
                      
                      // Team Selector
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(child: _buildTeamCard(Team.us)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTeamCard(Team.them)),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
                         child: Keypad(
                          value: _points,
                          isValid: _points.isNotEmpty,
                          onKeyPress: _handleKeyPress,
                          onDelete: _handleDelete,
                          onClear: _handleClear,
                          onConfirm: _handleConfirm,
                        ),
                      ),
                      const SizedBox(height: 32), // Bottom padding for scroll
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    final isSelected = _selectedWinner == team;
    final isUs = team == Team.us;
    final color = isUs ? AppColors.teamUs : AppColors.teamThem;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedWinner = team),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha:0.1) : Colors.white.withValues(alpha:0.05),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha:0.05),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isSelected ? (_points.isEmpty ? "0" : _points) : (_points.isEmpty ? "0" : _points),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha:0.3),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isUs ? context.read<GameProvider>().nameUs.toUpperCase() : context.read<GameProvider>().nameThem.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? color : Colors.white.withValues(alpha:0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
