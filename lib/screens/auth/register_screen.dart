import 'package:blisso_mobile/components/button_component.dart';
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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: TextFormField(
                        controller: firstname,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.person),
                            hintText: 'Enter your Firstname',
                            labelText: 'Firstname *'),
                        validator: (value) {
                          return (value == null
                              ? 'Your firstname should be present'
                              : null);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: TextFormField(
                        controller: lastname,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.person),
                            hintText: 'Enter your Lastname',
                            labelText: 'Lastname *'),
                        validator: (value) {
                          return (value == null
                              ? 'Your lastname should be present'
                              : null);
                        },
                      ),
                    ),
                    widget.type == 'EMAIL'
                        ? Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: TextFormField(
                              controller: emailUsername,
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.person),
                                  hintText: 'Enter your Email',
                                  labelText: 'Email *'),
                              validator: (value) {
                                return (value == null
                                    ? 'Your email should be present'
                                    : null);
                              },
                            ),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: TextFormField(
                              controller: phoneUsername,
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.person),
                                  hintText: 'Enter your phone number',
                                  labelText: 'Phone *'),
                              validator: (value) {
                                return (value == null
                                    ? 'Your phone should be present'
                                    : null);
                              },
                            ),
                          ),
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
                                    Routemaster.of(context)
                                        .push('/matching-selection');
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
                                  Routemaster.of(context).push('/Login');
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
