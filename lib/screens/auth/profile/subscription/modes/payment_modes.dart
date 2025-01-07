import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class PaymentModes extends StatelessWidget {
  final Function payByCard;
  final Function payByMomo;
  final bool isMomoEnabled;
  const PaymentModes(
      {super.key,
      required this.payByCard,
      required this.payByMomo,
      required this.isMomoEnabled});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose a Payment Option',
              style: TextStyle(color: GlobalColors.primaryColor),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: ButtonComponent(
                  text: 'Pay By Card',
                  backgroundColor: GlobalColors.primaryColor,
                  foregroundColor: GlobalColors.secondaryColor,
                  onTap: () => payByCard()),
            ),
            isMomoEnabled
                ? ButtonComponent(
                    text: 'Pay By Mobile Money',
                    backgroundColor: GlobalColors.primaryColor,
                    foregroundColor: GlobalColors.secondaryColor,
                    onTap: () => payByMomo())
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}

void showPaymentModes(
    {required BuildContext context,
    required Function payByCard,
    required Function payByMomo,
    bool isMomoEnabled = true}) {
  showDialog(
    context: context,
    builder: (context) {
      return PaymentModes(
        payByCard: payByCard,
        payByMomo: payByMomo,
        isMomoEnabled: isMomoEnabled,
      );
    },
  );
}
