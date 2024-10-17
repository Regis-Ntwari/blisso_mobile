import 'package:flutter/material.dart';

class PillButtonComponent extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  const PillButtonComponent(
      {super.key,
      required this.text,
      required this.buttonColor,
      required this.onPressed,
      required this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), //
      ),
      child: Text(
        text,
        style: TextStyle(color: foregroundColor),
      ),
    );
  }
}
