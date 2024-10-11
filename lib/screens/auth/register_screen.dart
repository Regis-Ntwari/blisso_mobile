import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/services/auth/user_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String type;
  const RegisterScreen({super.key, required this.type});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final firstname = TextEditingController();
  final lastname = TextEditingController();

  final emailUsername = TextEditingController();
  final phoneUsername = TextEditingController(text: '+250 ');

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userServiceProviderImpl);

    TextScaler textScaler = MediaQuery.textScalerOf(context);
    return SafeArea(
      child: Scaffold(
        body: userState.isLoading
            ? const LoadingScreen()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 16),
                    child: Text(
                      'Register',
                      style: TextStyle(
                          color: GlobalColors.primaryColor,
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
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ButtonComponent(
                                        text: 'Register',
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        onTap: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _formKey.currentState!.save();

                                            await ref
                                                .read(userServiceProviderImpl
                                                    .notifier)
                                                .registerUser(
                                                    widget.type == 'EMAIL'
                                                        ? emailUsername.text
                                                        : phoneUsername.text,
                                                    firstname.text,
                                                    lastname.text,
                                                    widget.type);

                                            final userState = ref
                                                .read(userServiceProviderImpl);
                                            if (userState.error != null) {
                                              showSnackBar(
                                                  context, userState.error!);
                                            } else {
                                              Routemaster.of(context)
                                                  .push('/password');
                                            }
                                          }
                                        })
                                  ],
                                ),
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
