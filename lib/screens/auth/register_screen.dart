import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class RegisterScreen extends StatefulWidget {
  final String type;
  const RegisterScreen({super.key, required this.type});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstname = TextEditingController();
  final lastname = TextEditingController();

  final emailUsername = TextEditingController();
  final phoneUsername = TextEditingController(text: '+250 ');

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler = MediaQuery.textScalerOf(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 16),
              child: Text(
                'Register',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 48,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "Provide your personal details to create your account",
                style: TextStyle(fontSize: textScaler.scale(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextInputComponent(
                        controller: firstname,
                        labelText: 'Firstname *',
                        hintText: 'Enter your Firstname',
                        validatorFunction: (value) {
                          return (value!.isEmpty
                              ? 'Your firstname should be present'
                              : null);
                        }),
                    TextInputComponent(
                        controller: lastname,
                        labelText: 'Lastname *',
                        hintText: 'Enter your lastname',
                        validatorFunction: (value) {
                          return (value!.isEmpty
                              ? 'Your lastname should be present'
                              : null);
                        }),
                    widget.type == 'EMAIL'
                        ? TextInputComponent(
                            controller: emailUsername,
                            labelText: 'Email *',
                            hintText: 'Enter your Email',
                            validatorFunction: (value) {
                              return (value!.isEmpty
                                  ? 'Your email should be present'
                                  : null);
                            })
                        : TextInputComponent(
                            controller: phoneUsername,
                            labelText: 'Phone number',
                            hintText: 'Enter your Phone number',
                            validatorFunction: (value) {
                              return (value!.isEmpty
                                  ? 'Your phone number should be present'
                                  : null);
                            }),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ButtonComponent(
                                  text: 'Register',
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      Routemaster.of(context)
                                          .push('/matching-selection');
                                    }
                                  })
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                              child: Text(
                            'Already have an account? Click the below button',
                            style: TextStyle(fontSize: textScaler.scale(9)),
                          )),
                          SizedBox(
                            child: ButtonComponent(
                                text: 'Login',
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return const LoadingScreen();
                                        });
                                    Future.delayed(const Duration(seconds: 3),
                                        () {
                                      Routemaster.of(context).pop();
                                      Routemaster.of(context).push('/Login');
                                    });
                                  }
                                }),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
