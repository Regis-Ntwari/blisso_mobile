import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/services/auth/user_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final usernameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final state = ref.watch(userServiceProviderImpl);

    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return SafeArea(
        child: Scaffold(
      backgroundColor: isLightTheme ? GlobalColors.lightBackgroundColor : null,
      body: state.isLoading
          ? const LoadingScreen()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 16),
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: GlobalColors.primaryColor,
                        fontSize: 48,
                        fontWeight: FontWeight.bold),
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
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await SharedPreferencesService
                                        .setPreference('username',
                                            usernameController.text);

                                    await ref
                                        .read(userServiceProviderImpl.notifier)
                                        .generateLoginCode();

                                    final userState =
                                        ref.read(userServiceProviderImpl);
                                    if (userState.error != null) {
                                      showSnackBar(context, userState.error!);
                                    } else {
                                      Routemaster.of(context).push("/password");
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
