import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class PinVerification extends StatelessWidget {
  final TextEditingController otpController;
  final Function verifyPin;
  const PinVerification(
      {super.key, required this.otpController, required this.verifyPin});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                ButtonComponent(
                    text: 'Verify',
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