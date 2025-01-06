import 'package:blisso_mobile/components/button_loading_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class CardPayment extends ConsumerWidget {
  final TextEditingController cardNames;
  final TextEditingController cardNumber;
  final TextEditingController expirationDate;
  final TextEditingController cvv;
  final Function initiatePayment;
  CardPayment(
      {super.key,
      required this.cardNames,
      required this.cardNumber,
      required this.expirationDate,
      required this.cvv,
      required this.initiatePayment});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionServiceProviderImpl);
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    Routemaster.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: GlobalColors.secondaryColor),
                    child: const Icon(
                      Icons.close,
                      color: GlobalColors.primaryColor,
                      size: 50,
                    ),
                  ),
                ),
              ),
              Flexible(
                  child: TextInputComponent(
                      controller: cardNumber,
                      labelText: 'Card Number',
                      hintText: 'Card Number',
                      validatorFunction: () {})),
              Flexible(
                  child: TextInputComponent(
                      controller: cardNames,
                      labelText: 'Card Names',
                      hintText: 'Card Names',
                      validatorFunction: () {})),
              Row(
                children: [
                  Flexible(
                      child: TextInputComponent(
                    controller: expirationDate,
                    labelText: 'Expiration Date',
                    hintText: 'MM/YY',
                    validatorFunction: () {},
                    keyboardType: TextInputType.number,
                  )),
                  Flexible(
                      child: TextInputComponent(
                    controller: cvv,
                    labelText: 'CVV',
                    hintText: 'CVV',
                    validatorFunction: () {},
                    keyboardType: TextInputType.number,
                  ))
                ],
              ),
              ButtonLoadingComponent(
                  widget: subscriptionState.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                        )
                      : const Text('Pay'),
                  backgroundColor: GlobalColors.primaryColor,
                  foregroundColor: GlobalColors.whiteColor,
                  onTap: () => initiatePayment())
            ],
          ),
        ),
      ),
    );
  }
}

void showCardPayment(
    {required BuildContext context,
    required TextEditingController cardNames,
    required TextEditingController cardNumber,
    required TextEditingController expirationDate,
    required TextEditingController cvv,
    required Function initiatePayment}) {
  showDialog(
    context: context,
    builder: (context) {
      return CardPayment(
          cardNames: cardNames,
          cardNumber: cardNumber,
          expirationDate: expirationDate,
          cvv: cvv,
          initiatePayment: initiatePayment);
    },
  );
}
