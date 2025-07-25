import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class ButtonLoadingComponent extends StatelessWidget {
  final Widget widget;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;
  final double? buttonHeight;
  final double? buttonWidth;
  const ButtonLoadingComponent(
      {super.key,
      required this.widget,
      required this.backgroundColor,
      required this.foregroundColor,
      required this.onTap,
      this.buttonHeight,
      this.buttonWidth});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: buttonWidth ?? width * 0.90,
        height: buttonHeight ?? height * 0.06,
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: GlobalColors.primaryColor),
        child: Align(alignment: Alignment.center, child: widget),
      ),
    );
  }
}
