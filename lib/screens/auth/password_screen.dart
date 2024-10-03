import 'dart:io';

import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:telephony/telephony.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final Telephony telephony = Telephony.instance;

  final passwordController = TextEditingController();

  void startListen() {
    // Platform.isAndroid
    //     ? telephony.listenIncomingSms(
    //         onNewMessage: (smsMessage) {
    //           if (smsMessage.body!.contains('Blisso')) {
    //             setState(() {
    //               passwordController.text = smsMessage.body!.substring(0, 6);
    //             });
    //           }
    //         },
    //         listenInBackground: false)
    //     : null;
  }

  @override
  void initState() {
    super.initState();
    startListen();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);

    String username =
        SharedPreferencesService.getPreference('username') as String;

    return SafeArea(
        child: Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 16),
            child: Text(
              'Verify OTP',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.red, fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Provide one-time password generated to $username",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: scaler.scale(12),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                  key: _formKey,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: TextInputComponent(
                        controller: passwordController,
                        labelText: 'Password *',
                        hintText: 'Enter your password',
                        validatorFunction: (value) {
                          return (value!.isEmpty
                              ? 'Your password should be present'
                              : null);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ButtonComponent(
                          text: 'Login',
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              Routemaster.of(context)
                                  .push('/matching-selection');
                            }
                          }),
                    ),
                  ])))
        ],
      ),
    ));
  }
}
