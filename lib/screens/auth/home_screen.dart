import 'package:blisso_mobile/components/biometric_button_component.dart';
import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _codeController = TextEditingController();

  bool isCodeClicked = false;
  String username = 'Regis';
  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    double width = MediaQuery.sizeOf(context).width;
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/blisso.png'),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'WELCOME BACK, ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: scaler.scale(28),
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      username,
                      style: TextStyle(
                          fontSize: scaler.scale(28), color: Colors.grey[700]),
                    )
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(30),
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage(
                    'assets/images/avatar1.jpg',
                  ),
                ),
              ),
              isCodeClicked
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: width * 0.90,
                        child: TextInputComponent(
                            controller: _codeController,
                            labelText: 'One Time Password',
                            hintText: 'Enter your OTP',
                            validatorFunction: (value) {
                              return (value!.isEmpty
                                  ? 'Your phone number should be present'
                                  : null);
                            }),
                      ),
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ButtonComponent(
                    text: !isCodeClicked ? 'Generate Login Code' : 'Login',
                    backgroundColor: GlobalColors.primaryColor,
                    foregroundColor: Colors.white,
                    onTap: () {
                      setState(() {
                        if (!isCodeClicked) {
                          isCodeClicked = !isCodeClicked;
                        }
                      });
                    }),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Stack(
                  children: [
                    BiometricButtonComponent(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
