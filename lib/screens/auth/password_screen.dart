import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/components/success_snackbar_component.dart';
import 'package:blisso_mobile/services/auth/user_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';

class PasswordScreen extends ConsumerStatefulWidget {
  const PasswordScreen({super.key});

  @override
  ConsumerState<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends ConsumerState<PasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? username;
  bool _showRetry = false;

  void startListen() {
    // Platform.isAndroid
    //     ? telephony.listenIncomingSms(
    //         onNewMessage: (smsMessage) {
    //           if (smsMessage.body!.contains('Blisso')) {
    //             setState(() {
    //               _otpController.text = smsMessage.body!.substring(0, 6);
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

  Future<void> getUsername() async {
    await SharedPreferencesService.getPreference('username').then(
      (value) {
        setState(() {
          username = value!;
        });
      },
    );
  }

  void _retryLogin() {
    setState(() {
      _showRetry = false;
      _otpController.clear();
    });
    // Focus on the first pin field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> _handleLogin() async {
    if (_otpController.text.length != 8) {
      showSnackBar(context, 'Please enter the 8-digit verification code');
      return;
    }

    await ref.read(userServiceProviderImpl.notifier).loginUser(
          username!,
          _otpController.text,
        );

    final userState = ref.read(userServiceProviderImpl);

    if (userState.error != null) {
      setState(() {
        _showRetry = true;
      });
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

    final userState = ref.watch(userServiceProviderImpl);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    // Pinput theme matching HomeScreen
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
      body: userState.isLoading || username == null
          ? const LoadingScreen()
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Logo or Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: GlobalColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 50,
                          color: GlobalColors.primaryColor,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        AppLocalizations.of(context)!.otpVerifyTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: GlobalColors.primaryColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subtitle with username
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: GlobalColors.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppLocalizations.of(context) == null
                              ? 'Enter verification code sent to $username'
                              : AppLocalizations.of(context)!
                                  .otpVerifySubtitle(username!),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: scaler.scale(14),
                            color: GlobalColors.secondaryColor,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // OTP Input Section
                      Column(
                        children: [
                          Text(
                            'Enter your 8-digit verification code',
                            style: TextStyle(
                              fontSize: scaler.scale(14),
                              color: GlobalColors.secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Pin Code Input using Pinput
                          Pinput(
                            length: 8,
                            controller: _otpController,
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
                              _handleLogin();
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter exactly 8 numbers',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  GlobalColors.secondaryColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),

                      // Main Login Button
                      ButtonComponent(
                        text: 'Verify & Login',
                        backgroundColor: GlobalColors.primaryColor,
                        foregroundColor: Colors.white,
                        onTap: _handleLogin,
                      ),

                      const SizedBox(height: 16),

                      // Action buttons row with Retry
                      if (!userState.isLoading)
                        Column(
                          children: [
                            // Retry Button - Click to retry login with same code
                            TextButton.icon(
                              onPressed: _retryLogin,
                              icon: Icon(
                                Icons.refresh,
                                color: GlobalColors.primaryColor,
                                size: 20,
                              ),
                              label: Text(
                                'Retry Login',
                                style: TextStyle(
                                  color: GlobalColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Resend Code Button
                            TextButton(
                              onPressed: () async {
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
                                    'New verification code has been sent to your email',
                                  );
                                  setState(() {
                                    _otpController.clear();
                                    _showRetry = false;
                                  });
                                }
                              },
                              child: Text(
                                'Resend Code',
                                style: TextStyle(
                                  color: GlobalColors.secondaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                      // Show retry message if verification failed
                      if (_showRetry)
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: GlobalColors.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Verification failed. Click Retry to try again.',
                                    style: TextStyle(
                                      color: GlobalColors.primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),

                      // Security note
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: GlobalColors.secondaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: GlobalColors.secondaryColor.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security_outlined,
                              size: 20,
                              color: GlobalColors.secondaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Never share your verification code with anyone. Our staff will never ask for your code.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: GlobalColors.secondaryColor,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}