import 'package:flutter/material.dart';

void showSuccessSnackBar(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 0, // Top margin below the status bar
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 48, 130, 51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    ),
  );

  // Insert the OverlayEntry
  overlay.insert(overlayEntry);

  // Remove the Snackbar after a duration
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}
