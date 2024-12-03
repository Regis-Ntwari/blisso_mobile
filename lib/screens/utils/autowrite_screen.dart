import 'dart:async';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class AutowriteScreen extends StatefulWidget {
  final String fullText;
  final Duration duration;
  final String navigate;

  AutowriteScreen(fullText, duration, this.navigate, {super.key})
      : fullText = Uri.decodeComponent(fullText),
        duration = const Duration(milliseconds: 100);

  @override
  State<AutowriteScreen> createState() => _AutoWritingPageState();
}

class _AutoWritingPageState extends State<AutowriteScreen>
    with SingleTickerProviderStateMixin {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _timer;

  double iconWidth = 50;
  late AnimationController _animationController;
  late Animation<double> _pulsateAnimation;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _pulsateAnimation =
        Tween<double>(begin: 50.0, end: 100.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
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

        await Future.delayed(const Duration(seconds: 2));

        Routemaster.of(context).push('/${widget.navigate}');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLightTheme
                      ? [
                          GlobalColors.lightBackgroundColor,
                          GlobalColors.primaryColor,
                        ]
                      : [
                          GlobalColors.primaryColor,
                          Colors.black,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: AnimatedOpacity(
                        opacity: _displayedText.isNotEmpty ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _displayedText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: scaler.scale(48),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black45,
                                offset: Offset(3.0, 3.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _pulsateAnimation,
                      builder: (context, child) {
                        return Icon(
                          Icons.favorite,
                          size: _pulsateAnimation.value,
                          color: GlobalColors.primaryColor,
                        );
                      },
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
