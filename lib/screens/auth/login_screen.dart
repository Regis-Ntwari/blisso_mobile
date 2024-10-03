import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
              "Provide email or phone number you used to generate a one time password to your account",
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
                    TextInputComponent(
                        controller: usernameController,
                        labelText: 'Username *',
                        hintText: 'Enter your username',
                        validatorFunction: (value) {
                          return (value!.isEmpty
                              ? 'Your username should be present'
                              : null);
                        }),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ButtonComponent(
                          text: 'Generate Code',
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              Routemaster.of(context)
                                  .push('/password/${usernameController.text}');
                            }
                          }),
                    ),
                  ])))
        ],
      ),
    ));
  }
}
