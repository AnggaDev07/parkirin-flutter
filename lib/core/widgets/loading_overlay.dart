// lib/core/widgets/loading_overlay.dart

import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;
  final Widget? lottieAsset;

  const LoadingOverlay({
    super.key,
    required this.message,
    this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    // Use Material as root widget to cover the entire screen
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        // Make it cover the full screen including status bar
        fit: StackFit.expand,
        children: [
          // Semi-transparent background
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // Loading content
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lottieAsset != null) ...[
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: lottieAsset!,
                    ),
                  ] else ...[
                    const CircularProgressIndicator(),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
