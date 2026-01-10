import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class Keypad extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback onConfirm;
  final String value;
  final bool isValid;

  const Keypad({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    required this.onClear,
    required this.onConfirm,
    required this.value,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'C', '0'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...keys.map((k) => _buildKey(k)),
              _buildDeleteKey(),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: isValid ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.white10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: isValid ? 8 : 0,
                shadowColor: AppColors.primary.withValues(alpha: 0.5), // Flutter 3.10+ opacity
              ),
              child: Text(
                'CONFIRMAR PUNTOS',
                style: TextStyle(
                  color: isValid ? Colors.white : Colors.white30,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String k) {
    final isClear = k == 'C';
    return Material(
      color: isClear ? Colors.red.withValues(alpha:0.1) : Colors.white.withValues(alpha:0.05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => isClear ? onClear() : onKeyPress(k),
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Text(
            k,
            style: TextStyle(
              color: isClear ? Colors.red : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return Material(
      color: Colors.white.withValues(alpha:0.05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onDelete,
        borderRadius: BorderRadius.circular(16),
        child: const Center(
          child: Icon(Icons.backspace_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
