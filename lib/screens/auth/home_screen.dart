import 'package:blisso_mobile/components/biometric_button_component.dart';
import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/services/auth/user_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _codeController = TextEditingController();

  final LocalAuthentication _localAuthentication = LocalAuthentication();

  bool _canCheckBiometrics = false;

  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    getFirstnameAndUsername();
    _checkBiometrics();
  }

  String firstname = '';
  String? username;
  Future<void> getFirstnameAndUsername() async {
    await SharedPreferencesService.getPreference('firstname').then(
      (value) {
        setState(() {
          firstname = value!;
        });
      },
    );

    await SharedPreferencesService.getPreference('username').then(
      (value) {
        setState(() {
          username = value!;
        });
      },
    );
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _authenticateUsingBiometrics(BuildContext context) async {
    bool authenticated = false;

    try {
      authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(
          biometricOnly: true, // Only allow biometric authentication
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print(e.toString());
      showSnackBar(context, 'Authentication failed: $e');
    }

    if (authenticated) {
      await ref.read(userServiceProviderImpl.notifier).loginBio();

      final userState = ref.read(userServiceProviderImpl);
      if (userState.error != null) {
        showSnackBar(context, userState.error!);
      } else {
        Routemaster.of(context).push('/profile/');
      }
    }
  }

  bool isCodeClicked = false;

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    double width = MediaQuery.sizeOf(context).width;

    final userState = ref.watch(userServiceProviderImpl);

    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    return SafeArea(
        child: Scaffold(
      backgroundColor: isLightTheme ? GlobalColors.lightBackgroundColor : null,
      body: userState.isLoading
          ? const LoadingScreen()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/blisso.png'),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'WELCOME BACK, ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: scaler.scale(28),
                                color: GlobalColors.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            firstname,
                            style: TextStyle(
                                fontSize: scaler.scale(28),
                                color: Colors.grey[700]),
                          )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: AssetImage(
                          'assets/images/avatar1.jpg',
                        ),
                      ),
                    ),
                    isCodeClicked
                        ? Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: SizedBox(
                              width: width * 0.90,
                              child: TextInputComponent(
                                  controller: _codeController,
                                  labelText: 'One Time Password',
                                  hintText: 'Enter your OTP',
                                  validatorFunction: (value) {
                                    return (value!.isEmpty
                                        ? 'Your phone number should be present'
                                        : null);
                                  }),
                            ),
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ButtonComponent(
                          text:
                              !isCodeClicked ? 'Generate Login Code' : 'Login',
                          backgroundColor: GlobalColors.primaryColor,
                          foregroundColor:
                              const Color.fromRGBO(255, 255, 255, 1),
                          onTap: () async {
                            if (!isCodeClicked) {
                              await ref
                                  .read(userServiceProviderImpl.notifier)
                                  .generateLoginCode();

                              final userState =
                                  ref.read(userServiceProviderImpl);
                              if (userState.error != null) {
                                showSnackBar(context, userState.error!);
                              }
                            } else {
                              await ref
                                  .read(userServiceProviderImpl.notifier)
                                  .loginUser(username!, _codeController.text);

                              final userState =
                                  ref.read(userServiceProviderImpl);
                              if (userState.error != null) {
                                showSnackBar(context, userState.error!);
                              } else {
                                Routemaster.of(context).push('/profile');
                              }
                            }
                            setState(() {
                              if (!isCodeClicked) {
                                isCodeClicked = !isCodeClicked;
                              }
                            });
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Stack(
                        children: [
                          _canCheckBiometrics
                              ? BiometricButtonComponent(
                                  onTap: () async {
                                    await _authenticateUsingBiometrics(context);
                                  },
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    ));
  }
}
