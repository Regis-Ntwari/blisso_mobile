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
    return InkWell(
      onTap: onTap,
      child: Container(
        color: backgroundColor,
        padding:
            const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
        child: Wrap(children: [
          Text(
            text,
            style: TextStyle(color: foregroundColor),
          ),
        ]),
      ),
    );
  }
}
