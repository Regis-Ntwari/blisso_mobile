import 'package:blisso_mobile/components/button_component.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
              'Register',
              style: TextStyle(
                  color: Colors.red, fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Provide your personal details to create your account",
              style: TextStyle(fontSize: scaler.scale(12)),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                  child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'Enter your Username',
                        labelText: 'username *'),
                    validator: (value) {
                      return (value == null
                          ? 'Your username should be present'
                          : null);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ButtonComponent(
                      text: 'Generate Code',
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
