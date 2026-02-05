import 'package:blisso_mobile/components/biometric_button_component.dart';
import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/components/success_snackbar_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/services/auth/user_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    getFirstnameAndUsername();
    _checkBiometrics();
  }

  String firstname = '';
  String? username;
  String? profilePicture;
  bool? isLoginCodeEnabled;
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

    await SharedPreferencesService.getPreference('profile_picture')
        .then((value) {
      setState(() {
        profilePicture = value;
      });
    });

    await SharedPreferencesService.getPreference('login_code_enabled')
        .then((value) async {
      if (value == null) {
        await SharedPreferencesService.setPreference(
            'login_code_enabled', true);

        getFirstnameAndUsername();
      } else {
        setState(() {
          isLoginCodeEnabled = value;
        });
      }
    });
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
      showSnackBar(context, 'Authentication failed: $e');
    }

    if (authenticated) {
      await ref.read(userServiceProviderImpl.notifier).loginBio();

      final userState = ref.read(userServiceProviderImpl);
      if (userState.error != null) {
        showSnackBar(context, userState.error!);
      } else {
        SharedPreferences prefs =
            await SharedPreferencesService.getSharedPreferences();

        if (prefs.get('is_profile_completed').toString() == 'true') {
          Routemaster.of(context).replace('/homepage');
        } else if (prefs.get('is_target_snapshots').toString() == 'true') {
          Routemaster.of(context).push('/profile-pictures');
        } else if (prefs.get('is_my_snapshots').toString() == 'true') {
          Routemaster.of(context).push('/target-snapshot');
        } else if (prefs.get('is_profile_created').toString() == 'true') {
          Routemaster.of(context).replace('/snapshots');
        } else if (prefs.get('isRegistered').toString() == 'true') {
          Routemaster.of(context).replace('/profile/');
        }
      }
    }
  }

  bool isCodeClicked = false;

  Future<void> _handleLogin() async {
    if (_codeController.text.length != 8) {
      showSnackBar(context, 'Please enter the 8-digit verification code');
      return;
    }

    await ref.read(userServiceProviderImpl.notifier).loginUser(
          username!,
          _codeController.text,
        );

    final userState = ref.read(userServiceProviderImpl);

    if (userState.error != null) {
      showSnackBar(context, userState.error!);
    } else {
      SharedPreferences prefs =
          await SharedPreferencesService.getSharedPreferences();

      if (prefs.get('is_profile_completed').toString() == 'true') {
        Routemaster.of(context).replace('/homepage');
      } else if (prefs.get('is_target_snapshots').toString() == 'true') {
        Routemaster.of(context).push('/profile-pictures');
      } else if (prefs.get('is_my_snapshots').toString() == 'true') {
        Routemaster.of(context).push('/target-snapshot');
      } else if (prefs.get('is_profile_created').toString() == 'true') {
        Routemaster.of(context).replace('/snapshots');
      } else if (prefs.get('isRegistered').toString() == 'true') {
        Routemaster.of(context).replace('/profile/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    final userState = ref.watch(userServiceProviderImpl);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    // Pinput theme
    final defaultPinTheme = PinTheme(
      width: 45,
      height: 55,
      textStyle: TextStyle(
        fontSize: 24,
        color: isLightTheme ? Colors.black : Colors.white,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.grey.shade100 : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GlobalColors.secondaryColor.withOpacity(0.3),
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: GlobalColors.primaryColor),
      color: isLightTheme ? Colors.grey.shade200 : Colors.grey.shade800,
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: GlobalColors.primaryColor),
      color: GlobalColors.primaryColor.withOpacity(0.1),
    );

    return Scaffold(
      backgroundColor:
          isLightTheme ? GlobalColors.lightBackgroundColor : Colors.black,
      body: userState.isLoading
          ? const LoadingScreen()
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  height: height,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        SizedBox(
                          height: height * 0.08,
                          child: Image.asset(
                            'assets/images/blisso.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // Welcome Message
                        Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.welcomeBack,
                              style: TextStyle(
                                fontSize: scaler.scale(24),
                                color: GlobalColors.secondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              firstname,
                              style: TextStyle(
                                fontSize: scaler.scale(32),
                                color: GlobalColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Profile Picture
                        Stack(
                          children: [
                            Container(
                              width: width * 0.35,
                              height: width * 0.35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: GlobalColors.primaryColor,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: GlobalColors.primaryColor
                                        .withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: profilePicture == null
                                    ? Image.asset(
                                        'assets/images/avatar1.jpg',
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: profilePicture!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(
                                            color: GlobalColors.primaryColor,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.person,
                                          size: width * 0.15,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                            ),
                            
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Verification Code Section
                        if (isLoginCodeEnabled != null && isLoginCodeEnabled!)
                          Column(
                            children: [
                              if (isCodeClicked)
                                Column(
                                  children: [
                                    Text(
                                      'Enter your 8-digit verification code',
                                      style: TextStyle(
                                        fontSize: scaler.scale(14),
                                        color: GlobalColors.secondaryColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    // Pin Code Input using Pinput
                                    Pinput(
                                      length: 8,
                                      controller: _codeController,
                                      defaultPinTheme: defaultPinTheme,
                                      focusedPinTheme: focusedPinTheme,
                                      submittedPinTheme: submittedPinTheme,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.length != 8) {
                                          return 'Enter 8 digits';
                                        }
                                        if (int.tryParse(value) == null) {
                                          return 'Numbers only';
                                        }
                                        return null;
                                      },
                                      showCursor: true,
                                      onCompleted: (pin) {
                                        // Auto-submit when all digits entered
                                        _handleLogin();
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Enter exactly 8 numbers',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: GlobalColors.secondaryColor
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                )
                              else
                                // Column(
                                //   children: [
                                //     Container(
                                //       padding: const EdgeInsets.symmetric(
                                //         horizontal: 20,
                                //         vertical: 12,
                                //       ),
                                //       decoration: BoxDecoration(
                                //         color: GlobalColors.primaryColor
                                //             .withOpacity(0.1),
                                //         borderRadius: BorderRadius.circular(16),
                                //         border: Border.all(
                                //           color: GlobalColors.primaryColor
                                //               .withOpacity(0.3),
                                //         ),
                                //       ),
                                //       child: Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.center,
                                //         children: [
                                //           Icon(
                                //             Icons.info_outline_rounded,
                                //             color: GlobalColors.primaryColor,
                                //             size: 20,
                                //           ),
                                //           const SizedBox(width: 8),
                                //           Flexible(
                                //             child: Text(
                                //               'Login code verification is enabled',
                                //               style: TextStyle(
                                //                 color: GlobalColors.primaryColor,
                                //                 fontWeight: FontWeight.w500,
                                //               ),
                                //               textAlign: TextAlign.center,
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //     ),
                                //     const SizedBox(height: 16),
                                //   ],
                                // ),

                              // Generate Code / Login Button
                              ButtonComponent(
                                text: isCodeClicked
                                    ? 'Verify & Login'
                                    : 'Generate Verification Code',
                                backgroundColor: GlobalColors.primaryColor,
                                foregroundColor: Colors.white,
                                onTap: () async {
                                  if (!isCodeClicked) {
                                    // Generate code
                                    await ref
                                        .read(userServiceProviderImpl.notifier)
                                        .generateLoginCode();

                                    final userState =
                                        ref.read(userServiceProviderImpl);
                                    if (userState.error != null) {
                                      showSnackBar(context, userState.error!);
                                    } else {
                                      showSuccessSnackBar(
                                        context,
                                        'Verification code has been sent',
                                      );
                                      setState(() {
                                        isCodeClicked = true;
                                      });
                                    }
                                  } else {
                                    // Login with code
                                    if (_codeController.text.length != 8) {
                                      showSnackBar(
                                        context,
                                        'Please enter 8-digit code',
                                      );
                                      return;
                                    }
                                    await _handleLogin();
                                  }
                                },
                              ),

                              const SizedBox(height: 8),
                              if (isCodeClicked)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isCodeClicked = false;
                                      _codeController.clear();
                                    });
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: GlobalColors.secondaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        // Or Divider
                        if (_canCheckBiometrics &&
                            isLoginCodeEnabled != null &&
                            isLoginCodeEnabled!)
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color:
                                      GlobalColors.secondaryColor.withOpacity(0.3),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: GlobalColors.secondaryColor
                                        .withOpacity(0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color:
                                      GlobalColors.secondaryColor.withOpacity(0.3),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        // Biometric Authentication
                        if (_canCheckBiometrics)
                          Column(
                            children: [
                              Text(
                                'Quick Login',
                                style: TextStyle(
                                  fontSize: scaler.scale(14),
                                  color: GlobalColors.secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              BiometricButtonComponent(
                                onTap: () async {
                                  await _authenticateUsingBiometrics(context);
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Use fingerprint or face recognition',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: GlobalColors.secondaryColor
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),

                        // Spacer to push content up
                        const Spacer(),

                        // Footer note
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Text(
                            'Blisso Mobile App',
                            style: TextStyle(
                              fontSize: 12,
                              color: GlobalColors.secondaryColor
                                  .withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}