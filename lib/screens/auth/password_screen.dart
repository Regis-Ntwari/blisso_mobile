import 'dart:io';

import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/services/auth/user_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:telephony/telephony.dart';

class PasswordScreen extends ConsumerStatefulWidget {
  const PasswordScreen({super.key});

  @override
  ConsumerState<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends ConsumerState<PasswordScreen> {
  final Telephony telephony = Telephony.instance;

  final _passwordController = TextEditingController();

  String? username;

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
    getUsername();
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> getUsername() async {
    await SharedPreferencesService.getPreference('username').then(
      (value) {
        setState(() {
          username = value!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);

    final userState = ref.watch(userServiceProviderImpl);

    return SafeArea(
        child: Scaffold(
      body: userState.isLoading
          ? const LoadingScreen()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 16),
                  child: Text(
                    'Verify OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
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
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: TextInputComponent(
                              controller: _passwordController,
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
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await ref
                                        .read(userServiceProviderImpl.notifier)
                                        .loginUser(username!,
                                            _passwordController.text);

                                    final userState =
                                        ref.read(userServiceProviderImpl);
                                    if (userState.error != null) {
                                      showSnackBar(context, userState.error!);
                                    } else {
                                      Routemaster.of(context)
                                          .push('/matching-selection');
                                    }
                                  }
                                }),
                          ),
                        ])))
              ],
            ),
    ));
  }
}
