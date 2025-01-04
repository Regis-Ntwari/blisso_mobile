import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class PopupComponent extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? backgroundColor;
  final double borderRadius;

  const PopupComponent({
    super.key,
    required this.icon,
    this.iconColor = GlobalColors.primaryColor,
    this.iconSize = 64.0,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.backgroundColor,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 8.0,
      backgroundColor: backgroundColor ?? Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red[50],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalColors.primaryColor,
                ),
                child: Text(
                  'OK',
                  style: TextStyle(color: GlobalColors.whiteColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showPopupComponent({
  required BuildContext context,
  required IconData icon,
  required String message,
  String? buttonText,
  VoidCallback? onButtonPressed,
  Color? iconColor,
  double? iconSize,
  Color? backgroundColor,
  double? borderRadius,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PopupComponent(
        icon: icon,
        iconColor: iconColor ?? GlobalColors.primaryColor,
        iconSize: iconSize ?? 64.0,
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius ?? 16.0,
      );
    },
  );
}
