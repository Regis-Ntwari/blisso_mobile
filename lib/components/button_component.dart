import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class ButtonComponent extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;
  final double? buttonHeight;
  final double? buttonWidth;
  const ButtonComponent(
      {super.key,
      required this.text,
      required this.backgroundColor,
      required this.foregroundColor,
      required this.onTap,
      this.buttonHeight,
      this.buttonWidth});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: buttonWidth ?? width * 0.90,
        height: buttonHeight ?? height * 0.06,
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: GlobalColors.primaryColor,
          // gradient: LinearGradient(
          //   colors: !isLightTheme
          //       ? [
          //           GlobalColors.lightBackgroundColor,
          //           GlobalColors.primaryColor,
          //         ]
          //       : [
          //           GlobalColors.primaryColor,
          //           Colors.black87,
          //         ],
          // )
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isLightTheme ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
