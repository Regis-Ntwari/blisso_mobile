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

    return Scaffold(
      backgroundColor:
          isLightTheme ? GlobalColors.lightBackgroundColor : Colors.black,
      body: state.isLoading
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

                      // Icon or illustration
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: GlobalColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.login_rounded,
                          size: 50,
                          color: GlobalColors.primaryColor,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: GlobalColors.primaryColor,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subtitle
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
                          'Sign in to continue',
                          style: TextStyle(
                            fontSize: scaler.scale(14),
                            color: GlobalColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        "Provide your email to receive a one-time password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: scaler.scale(14),
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
                            // Username Input (Email/Phone)
                            TextInputComponent(
                              controller: usernameController,
                              labelText: 'Email  *',
                              hintText: 'Enter your email ',
                              keyboardType: TextInputType.emailAddress,
                              validatorFunction: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your email ';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // Generate Code Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await SharedPreferencesService
                                        .setPreference(
                                      'username',
                                      usernameController.text,
                                    );

                                    await ref
                                        .read(userServiceProviderImpl.notifier)
                                        .generateLoginCode();

                                    final userState =
                                        ref.read(userServiceProviderImpl);

                                    if (userState.error != null) {
                                      showSnackBar(context, userState.error!);
                                    } else {
                                      // showSuccessSnackBar(
                                      //   context,
                                      //   'Verification code has been sent to your email/phone',
                                      // );

                                      Routemaster.of(context).push("/password");
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GlobalColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Generate Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: GlobalColors.secondaryColor
                                        .withOpacity(0.3),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'New here?',
                                    style: TextStyle(
                                      color: GlobalColors.secondaryColor
                                          .withOpacity(0.5),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: GlobalColors.secondaryColor
                                        .withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Create Account Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () {
                                  // Navigate to registration type selection
                                  Routemaster.of(context)
                                      .push('/register/EMAIL');
                                  //_showRegistrationTypeDialog(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: GlobalColors.primaryColor,
                                  side: BorderSide(
                                    color: GlobalColors.primaryColor,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Create New Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Security Note
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    GlobalColors.primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: GlobalColors.primaryColor
                                      .withOpacity(0.1),
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
                                      'We\'ll send a one-time verification code to your email ',
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

                            // Help Text
                            TextButton(
                              onPressed: () {
                                // Navigate to help/support
                              },
                              child: Text(
                                'Need help signing in?',
                                style: TextStyle(
                                  color: GlobalColors.secondaryColor
                                      .withOpacity(0.7),
                                  fontSize: 13,
                                ),
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
