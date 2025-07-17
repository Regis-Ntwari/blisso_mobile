import 'package:blisso_mobile/components/button_loading_component.dart';
import 'package:blisso_mobile/components/expandable_text_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/screens/utils/subscription/chosen_options_provider.dart';
import 'package:blisso_mobile/screens/utils/subscription/previous_subscription_response_provider.dart';
import 'package:blisso_mobile/services/subscriptions/create_subscription_service_provider.dart';
import 'package:blisso_mobile/services/subscriptions/verify_card_details_service_provider.dart';
import 'package:blisso_mobile/services/subscriptions/verify_otp_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyOtp extends ConsumerStatefulWidget {
  const VerifyOtp({super.key});

  @override
  ConsumerState<VerifyOtp> createState() => _VerifyCardPinState();
}

class _VerifyCardPinState extends ConsumerState<VerifyOtp> {
  final TextEditingController pinController = TextEditingController();

  void verifyPin() async {
    final chosenOptions = ref.read(chosenOptionsProviderImpl);

    final verifyOtpProvider = ref.read(verifyOtpServiceProviderImpl.notifier);

    final previousData = ref.read(previousSubscriptionResponseProviderImpl);

    await verifyOtpProvider.verifyOtp({
      'transaction_id': previousData['transaction_id'],
      'otp': pinController.text
    });

    final paymentState = ref.read(verifyOtpServiceProviderImpl);


    if(paymentState.statusCode == 200 || paymentState.statusCode == 201) {
      
      final subscriptionProvider = ref.read(createSubscriptionProviderImpl.notifier);

      final previousData = ref.read(previousSubscriptionResponseProviderImpl);

      await subscriptionProvider.createSubscription({
        'plan_code': chosenOptions['code'],
        'price': chosenOptions['amount'],
        'currency': chosenOptions['currency'],
        'transaction_id': previousData['transaction_id']
      });

      Navigator.of(context).pop();
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
            child: ExpandableTextComponent(text: 'Provide your OTP sent to Email or Phone'),
          ),
          TextInputComponent(
              controller: pinController,
              keyboardType: TextInputType.number,
              labelText: 'OTP',
              hintText: 'Please Enter your OTP',
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
                        'Verify OTP',
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
