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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordScreen extends ConsumerStatefulWidget {
  const PasswordScreen({super.key});

  @override
  ConsumerState<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends ConsumerState<PasswordScreen> {
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
        debugPrint(username);
        debugPrint(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);

    final userState = ref.watch(userServiceProviderImpl);

    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    return SafeArea(
        child: Scaffold(
      backgroundColor:
          isLightTheme ? GlobalColors.lightBackgroundColor : Colors.black,
      body: userState.isLoading || username == null
          ? const LoadingScreen()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                  child: Text(
                    AppLocalizations.of(context)!.otpVerifyTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: GlobalColors.primaryColor,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    AppLocalizations.of(context) == null
                        ? username!
                        : AppLocalizations.of(context)!
                            .otpVerifySubtitle(username!),
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
                              labelText:
                                  '${AppLocalizations.of(context)!.password} *',
                              hintText:
                                  AppLocalizations.of(context)!.hintPassword,
                              validatorFunction: (value) {
                                return (value!.isEmpty
                                    ? AppLocalizations.of(context)!
                                        .validatorPassword
                                    : null);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ButtonComponent(
                                text: AppLocalizations.of(context)!.login,
                                backgroundColor: GlobalColors.primaryColor,
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
                                      SharedPreferences prefs =
                                          await SharedPreferencesService
                                              .getSharedPreferences();

                                      if (prefs
                                              .get('is_profile_completed')
                                              .toString() ==
                                          'true') {
                                        Routemaster.of(context)
                                            .replace('/homepage');
                                      } else if (prefs
                                              .get('is_target_snapshots')
                                              .toString() ==
                                          'true') {
                                        Routemaster.of(context)
                                            .push('/profile-pictures');
                                      } else if (prefs
                                              .get('is_my_snapshots')
                                              .toString() ==
                                          'true') {
                                        Routemaster.of(context)
                                            .push('/target-snapshot');
                                      } else if (prefs
                                              .get('is_profile_created')
                                              .toString() ==
                                          'true') {
                                        Routemaster.of(context)
                                            .replace('/snapshots');
                                      } else if (prefs
                                              .get('isRegistered')
                                              .toString() ==
                                          'true') {
                                        Routemaster.of(context)
                                            .replace('/profile/');
                                      }
                                      // Routemaster.of(context).push(
                                      //     "/auto-write/Hurrah... thanks for creating an account. Let's create your profile/profile/");
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
