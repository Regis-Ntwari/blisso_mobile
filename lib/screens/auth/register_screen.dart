import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/components/success_snackbar_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/services/auth/user_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../l10n/app_localizations.dart';

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
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userServiceProviderImpl);
    TextScaler textScaler = MediaQuery.textScalerOf(context);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLightTheme ? GlobalColors.lightBackgroundColor : Colors.black,
      body: userState.isLoading
          ? const LoadingScreen()
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

                      // Icon or illustration
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: GlobalColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 50,
                          color: GlobalColors.primaryColor,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        AppLocalizations.of(context)!.registerTitle,
                        style: TextStyle(
                          color: GlobalColors.primaryColor,
                          fontSize: textScaler.scale(36),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Registration type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: GlobalColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.type == 'EMAIL'
                              ? 'Register with Email'
                              : 'Register with Phone',
                          style: TextStyle(
                            fontSize: textScaler.scale(14),
                            color: GlobalColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        AppLocalizations.of(context)!.registerSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: textScaler.scale(14),
                          color: GlobalColors.secondaryColor.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Form Section
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // First Name
                            TextInputComponent(
                              controller: firstname,
                              labelText: '${AppLocalizations.of(context)!.firstname} *',
                              hintText: AppLocalizations.of(context)!.hintFirstname,
                              validatorFunction: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)!.validatorFirstname;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Last Name
                            TextInputComponent(
                              controller: lastname,
                              labelText: '${AppLocalizations.of(context)!.lastname} *',
                              hintText: AppLocalizations.of(context)!.hintLastname,
                              validatorFunction: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)!.validatorLastname;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Email/Phone Input
                            widget.type == 'EMAIL'
                                ? TextInputComponent(
                                    controller: emailUsername,
                                    labelText: '${AppLocalizations.of(context)!.email} *',
                                    hintText: AppLocalizations.of(context)!.hintEmail,
                                    keyboardType: TextInputType.emailAddress,
                                    validatorFunction: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!.validatorEmail;
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Enter a valid email address';
                                      }
                                      return null;
                                    },
                                  )
                                : TextInputComponent(
                                    controller: phoneUsername,
                                    labelText: AppLocalizations.of(context)!.phoneNumber,
                                    hintText: AppLocalizations.of(context)!.hintPhoneNumber,
                                    keyboardType: TextInputType.phone,
                                    validatorFunction: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!.validatorPhoneNumber;
                                      }
                                      if (value.length < 12) {
                                        return 'Enter a valid phone number';
                                      }
                                      return null;
                                    },
                                  ),

                            // Terms and Conditions
                            // Row(
                            //   children: [
                            //     SizedBox(
                            //       width: 24,
                            //       height: 24,
                            //       child: Checkbox(
                            //         value: true, // You can make this stateful if needed
                            //         onChanged: (value) {},
                            //         activeColor: GlobalColors.primaryColor,
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(4),
                            //         ),
                            //       ),
                            //     ),
                            //     const SizedBox(width: 8),
                            //     Expanded(
                            //       child: Text(
                            //         'I agree to the Terms of Service and Privacy Policy',
                            //         style: TextStyle(
                            //           fontSize: 13,
                            //           color: GlobalColors.secondaryColor.withOpacity(0.8),
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),

                            const SizedBox(height: 24),

                            // Register Button
                            ButtonComponent(
                              text: 'Create Account',
                              backgroundColor: GlobalColors.primaryColor,
                              foregroundColor: Colors.white,
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();

                                  await ref
                                      .read(userServiceProviderImpl.notifier)
                                      .registerUser(
                                        widget.type == 'EMAIL'
                                            ? emailUsername.text
                                            : phoneUsername.text,
                                        firstname.text,
                                        lastname.text,
                                        widget.type,
                                      );

                                  final userState = ref.read(userServiceProviderImpl);
                                  if (userState.error != null) {
                                    showSnackBar(context, userState.error!);
                                  } else {
                                    await SharedPreferencesService.setPreference(
                                      'username',
                                      widget.type == 'EMAIL'
                                          ? emailUsername.text
                                          : phoneUsername.text,
                                    );

                                    showSuccessSnackBar(
                                      context,
                                      'Account created successfully! Verification code sent.',
                                    );

                                    Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () {
                                        Routemaster.of(context).push("/password");
                                      },
                                    );
                                  }
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: GlobalColors.secondaryColor.withOpacity(0.3),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Already have an account?',
                                    style: TextStyle(
                                      color: GlobalColors.secondaryColor.withOpacity(0.5),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: GlobalColors.secondaryColor.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Login Button
                            ButtonComponent(
                              text: 'Sign In Instead',
                              backgroundColor: Colors.transparent,
                              foregroundColor: GlobalColors.primaryColor,
                              onTap: () => Routemaster.of(context).push('/Login'),
                            ),

                            const SizedBox(height: 32),

                            // Security Note
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: GlobalColors.primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: GlobalColors.primaryColor.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.security_rounded,
                                    size: 20,
                                    color: GlobalColors.primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Your information is securely encrypted and protected',
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

                            const SizedBox(height: 20),
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