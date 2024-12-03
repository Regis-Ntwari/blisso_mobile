import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.transparent,
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
                valueColor: AlwaysStoppedAnimation(GlobalColors.primaryColor),
              ),
            ),
          ),
        )
      ],
    );
  }
}
