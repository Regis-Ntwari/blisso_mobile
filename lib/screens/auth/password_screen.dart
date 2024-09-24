import 'package:blisso_mobile/components/button_component.dart';
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

class PasswordScreen extends StatefulWidget {
  final String username;
  const PasswordScreen({super.key, required this.username});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final Telephony telephony = Telephony.instance;

  final passwordController = TextEditingController();

  void startListen() {
    telephony.listenIncomingSms(
        onNewMessage: (smsMessage) {
          if (smsMessage.body!.contains('Blisso')) {
            setState(() {
              passwordController.text = smsMessage.body!.substring(0, 6);
            });
          }
        },
        listenInBackground: false);
  }

  @override
  void initState() {
    super.initState();
    startListen();
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    return SafeArea(
        child: Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 16),
            child: Text(
              'Login',
              style: TextStyle(
                  color: Colors.red, fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Provide one-time password generated to ${widget.username}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: scaler.scale(12),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                  child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'Enter your password',
                        labelText: 'password *'),
                    validator: (value) {
                      return (value == null
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
                      onTap: () {}),
                ),
              ])))
        ],
      ),
    ));
  }
}
