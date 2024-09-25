import 'package:flutter/material.dart';

class ButtonComponent extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;
  const ButtonComponent(
      {super.key,
      required this.text,
      required this.backgroundColor,
      required this.foregroundColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
            shadowColor: Colors.black,
            fixedSize: Size(width * 0.90, height * 0.05),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor),
        onPressed: onTap,
        child: Text(text));
  }
}
