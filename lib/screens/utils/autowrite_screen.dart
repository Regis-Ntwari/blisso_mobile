import 'dart:async';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class AutowriteScreen extends StatefulWidget {
  final String fullText; // The complete text to display
  final Duration duration; // Duration between each character display

  const AutowriteScreen({
    super.key,
    required this.fullText,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<AutowriteScreen> createState() => _AutoWritingPageState();
}

class _AutoWritingPageState extends State<AutowriteScreen> {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _timer;

  double iconWidth = 50;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.duration, (timer) async {
      if (_currentIndex < widget.fullText.length) {
        setState(() {
          _displayedText += widget.fullText[_currentIndex];
          _currentIndex++;
        });
      } else {
        setState(() {
          iconWidth = 200;
        });
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          iconWidth = 50;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    double height = MediaQuery.sizeOf(context).height;
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: height * 0.8,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    _displayedText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: scaler.scale(48),
                        fontWeight: FontWeight.bold,
                        color: GlobalColors.primaryColor),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  decoration: const BoxDecoration(
                      gradient: RadialGradient(colors: [
                    GlobalColors.primaryColor,
                    Colors.transparent
                  ])),
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.heart_broken,
                      size: iconWidth,
                      color: GlobalColors.primaryColor,
                    ),
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
