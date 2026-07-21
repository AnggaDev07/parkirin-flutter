// lib/features/driver/presentation/widgets/points_celebration_overlay.dart

import 'package:flutter/material.dart';

class PointsCelebrationOverlay extends StatelessWidget {
  final VoidCallback onDismiss;
  final int freeParkingChances;

  const PointsCelebrationOverlay({
    super.key,
    required this.onDismiss,
    required this.freeParkingChances,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.local_parking_rounded,
                size: 32,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🎉 Congratulations! 🎉',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You\'ve earned a free parking chance!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Total free parking chances: $freeParkingChances',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Awesome!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
