import 'dart:async';
import 'dart:ui';

import 'package:blisso_mobile/components/button_component.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  Timer? _timer;

  final List<Map<String, String>> _images = [
    {'image': 'assets/images/welcome1.jpg', 'text': 'Find Love in a Click'},
    {
      'image': 'assets/images/welcome2.jpg',
      'text': 'Pass Time with a Loved One'
    },
    {
      'image': 'assets/images/welcome3.jpg',
      'text': 'You know what? Click Below'
    }
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        Routemaster.of(context).push('/register/EMAIL');
      }

      _pageController.animateToPage(_currentPage,
          duration: const Duration(milliseconds: 1000), curve: Curves.easeIn);
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
    _pageController.dispose();
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _images.map((image) {
        int index = _images.indexOf(image);
        return Container(
          width: 10.0,
          height: 10.0,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.3),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(_images[index]['image']!),
                            fit: BoxFit.cover)),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              _images[index]['text']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 32),
                            ),
                            _buildPageIndicator(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ButtonComponent(
                                    onTap: () => Routemaster.of(context)
                                        .replace('/register/EMAIL'),
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red,
                                    text: 'Sign up with Email'),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ButtonComponent(
                                    onTap: () => Routemaster.of(context)
                                        .replace('/register/PHONE'),
                                    text: 'Sign up with Phone',
                                    foregroundColor: Colors.red,
                                    backgroundColor: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
