import 'package:blisso_mobile/components/button_loading_component.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PinVerification extends ConsumerWidget {
  final TextEditingController otpController;
  final Function verifyPin;
  const PinVerification(
      {super.key, required this.otpController, required this.verifyPin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionServiceProviderImpl);
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      child: Form(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Enter the PIN sent to you',
                    style: TextStyle(color: GlobalColors.primaryColor),
                  ),
                ),
                TextFormField(
                  controller: otpController,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 16),
                  decoration: InputDecoration(
                      counterText: "",
                      hintText: "----",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                  validator: (value) {
                    if (value == null || value.length != 4) {
                      return 'Enter a valid 4-digit OTP';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ButtonLoadingComponent(
                    widget: subscriptionState.isLoading
                        ? CircularProgressIndicator(
                            color: isLightTheme ? Colors.white : Colors.black,
                          )
                        : const Text('Verify'),
                    backgroundColor: GlobalColors.primaryColor,
                    foregroundColor: GlobalColors.lightBackgroundColor,
                    onTap: () => verifyPin())
              ],
            ),
          ),
        ),
      ),
    );
  }
}

showPinVerification(
    {required BuildContext context,
    required TextEditingController otpController,
    required Function verifyPin}) {
  showDialog(
    context: context,
    builder: (context) {
      return PinVerification(
        otpController: otpController,
        verifyPin: verifyPin,
      );
    },
  );
}
