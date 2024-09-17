import 'package:blisso_mobile/components/button_component.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final fullNames = TextEditingController();
  final nickname = TextEditingController();
  String gender = 'MALE';
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 16),
                child: Text(
                  'Register',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Form(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                                icon: Icon(Icons.person),
                                hintText: 'Enter Your Full Names',
                                labelText: 'Name *'),
                            validator: (value) {
                              return (value == null
                                  ? 'Your full name should be present'
                                  : null);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                                icon: Icon(Icons.weekend),
                                hintText: 'Enter Your Nickname',
                                labelText: 'Nickname *'),
                            validator: (value) {
                              return (value == null
                                  ? 'Your nickname should be present'
                                  : null);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, bottom: 8.0, left: 5),
                          child: DropdownButtonFormField(
                            hint: const Text('Select Your gender'),
                            value: gender,
                            elevation: 4,
                            onChanged: (String? value) {
                              setState(() {
                                gender = value!;
                              });
                            },
                            items: ['MALE', 'FEMALE']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem(
                                value: value,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    value == 'MALE'
                                        ? const Icon(Icons.male)
                                        : const Icon(Icons.female),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      value,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                                icon: Icon(Icons.verified_user),
                                hintText: 'Enter Your Username',
                                labelText: 'Username *'),
                            validator: (value) {
                              return (value == null
                                  ? 'Your username should be present'
                                  : null);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: TextFormField(
                            obscureText: !isPasswordVisible,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecoration(
                                suffixIcon: InkWell(
                                  onTap: () => setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  }),
                                  child: isPasswordVisible
                                      ? const Icon(Icons.visibility)
                                      : const Icon(Icons.visibility_off),
                                ),
                                icon: const Icon(Icons.lock),
                                hintText: 'Enter Your Password',
                                labelText: 'Password *'),
                            validator: (value) {
                              return (value == null
                                  ? 'Your password should be present'
                                  : null);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: TextFormField(
                            obscureText: !isConfirmPasswordVisible,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecoration(
                                suffixIcon: InkWell(
                                  onTap: () => setState(() {
                                    isConfirmPasswordVisible =
                                        !isConfirmPasswordVisible;
                                  }),
                                  child: isConfirmPasswordVisible
                                      ? const Icon(Icons.visibility)
                                      : const Icon(Icons.visibility_off),
                                ),
                                icon: const Icon(Icons.lock),
                                hintText: 'Confirm Your Password',
                                labelText: 'Confirm Password *'),
                            validator: (value) {
                              return (value == null
                                  ? 'Your password should be present'
                                  : null);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                  onTap: () {},
                                  child: ButtonComponent(
                                      text: 'Next',
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      onTap: () {
                                        Routemaster.of(context)
                                            .push('/matching-selection');
                                      }))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
