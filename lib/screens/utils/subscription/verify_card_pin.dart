import 'package:blisso_mobile/components/button_loading_component.dart';
import 'package:blisso_mobile/components/expandable_text_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/screens/utils/subscription/chosen_options_provider.dart';
import 'package:blisso_mobile/screens/utils/subscription/previous_subscription_response_provider.dart';
import 'package:blisso_mobile/services/subscriptions/create_subscription_service_provider.dart';
import 'package:blisso_mobile/services/subscriptions/verify_card_details_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class VerifyCardPin extends ConsumerStatefulWidget {
  const VerifyCardPin({super.key});

  @override
  ConsumerState<VerifyCardPin> createState() => _VerifyCardPinState();
}

class _VerifyCardPinState extends ConsumerState<VerifyCardPin> {
  final TextEditingController pinController = TextEditingController();

  void verifyPin() async {
    final chosenOptionRef = ref.read(chosenOptionsProviderImpl);

    final verifyProvider = ref.read(verifyCardDetailsProviderImpl.notifier);

    final previousData = ref.read(previousSubscriptionResponseProviderImpl);

    await verifyProvider.verifyCardDetails({
      ...previousData,
      'authorization': {
        'mode': 'pin',
        "pin": int.parse(pinController.text),
      }
    });

    final paymentState = ref.read(verifyCardDetailsProviderImpl);

    if (paymentState.statusCode == 200 || paymentState.statusCode == 201) {
      final subscriptionProvider =
          ref.read(createSubscriptionProviderImpl.notifier);

      final chosenOptions = ref.read(chosenOptionsProviderImpl);

      await subscriptionProvider.createSubscription({
        'plan_code': chosenOptions['code'],
        'price': chosenOptions['amount'],
        'currency': chosenOptions['currency'],
        'transaction_id': paymentState.data['transaction_id']
      });

      Routemaster.of(context).pop();
    } else if (paymentState.statusCode == 307) {
      // go to the OTP screen

      final previousRef =
          ref.read(previousSubscriptionResponseProviderImpl.notifier);

      previousRef.resetOptions();

      previousRef.addWholeMap(paymentState.data);

      // navigate to otp screen

      Routemaster.of(context).replace("/homepage/verify-otp");
    } else {
      showSnackBar(context, paymentState.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verifyCardDetailsRef = ref.watch(verifyCardDetailsProviderImpl);
    final createSubscriptionRef = ref.watch(createSubscriptionProviderImpl);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.keyboard_arrow_left)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30.0),
            child: ExpandableTextComponent(text: 'Provide your Card PIN'),
          ),
          TextInputComponent(
              controller: pinController,
              keyboardType: TextInputType.number,
              labelText: 'PIN',
              hintText: 'Please Enter your PIN',
              validatorFunction: () {}),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ButtonLoadingComponent(
                widget: verifyCardDetailsRef.isLoading ||
                        createSubscriptionRef.isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Verify PIN',
                        style: TextStyle(color: Colors.white),
                      ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.white,
                onTap: verifyPin),
          )
        ],
      ),
    ));
  }
}
