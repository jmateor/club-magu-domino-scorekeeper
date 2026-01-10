import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../screens/home_screen.dart';

class StartGameDialog extends StatefulWidget {
  final bool isReset;
  
  const StartGameDialog({super.key, this.isReset = false});

  @override
  State<StartGameDialog> createState() => _StartGameDialogState();
}

class _StartGameDialogState extends State<StartGameDialog> {
  late TextEditingController _nameUsController;
  late TextEditingController _nameThemController;
  bool _useDefaultNames = false;

  @override
  void initState() {
    super.initState();
    final game = context.read<GameProvider>();
    // Pre-fill with existing names if we are resetting, to allow minor edits
    _nameUsController = TextEditingController(text: game.nameUs);
    _nameThemController = TextEditingController(text: game.nameThem);
  }

  @override
  void dispose() {
    _nameUsController.dispose();
    _nameThemController.dispose();
    super.dispose();
  }

  void _startGame() {
    final game = context.read<GameProvider>();
    
    String us = _nameUsController.text.trim();
    String them = _nameThemController.text.trim();

    if (_useDefaultNames || us.isEmpty) us = "Nosotros";
    if (_useDefaultNames || them.isEmpty) them = "Ellos";

    game.setNames(us, them);
    game.resetGame(); // This restarts the game state and timer

    Navigator.of(context).pop(); // Close dialog

    // If we are not already on HomeScreen (e.g. from WelcomeScreen), navigate there
    // We check if the current route is NOT HomeScreen to avoid stacking
    // Simple heuristic: If we are 'resetting' we are likely already there or in WinDialog.
    // If not isReset, we might be in WelcomeScreen.
    if (!widget.isReset) {
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        widget.isReset ? "Reiniciar Partida" : "Configurar Partida", 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isReset) 
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "¿Deseas comenzar de cero? Puedes cambiar los nombres o mantener los actuales.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            
            // Toggle for Defaults
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeTrackColor: AppColors.primary,
              title: const Text("Usar nombres por defecto", style: TextStyle(color: Colors.white)),
              value: _useDefaultNames,
              onChanged: (val) {
                setState(() {
                  _useDefaultNames = val;
                  if (val) {
                    _nameUsController.text = "Nosotros";
                    _nameThemController.text = "Ellos";
                  }
                });
              },
            ),
            
            const SizedBox(height: 8),

            // Inputs (Disabled if defaults checked)
            TextField(
              controller: _nameUsController,
              enabled: !_useDefaultNames,
              decoration: const InputDecoration(
                labelText: "Equipo 1",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameThemController,
              enabled: !_useDefaultNames,
              decoration: const InputDecoration(
                labelText: "Equipo 2",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(widget.isReset ? "Reiniciar" : "Jugar", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
