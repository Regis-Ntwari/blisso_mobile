import 'package:blisso_mobile/components/button_loading_component.dart';
import 'package:blisso_mobile/components/expandable_text_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/screens/utils/subscription/chosen_options_provider.dart';
import 'package:blisso_mobile/screens/utils/subscription/previous_subscription_response_provider.dart';
import 'package:blisso_mobile/services/subscriptions/create_subscription_service_provider.dart';
import 'package:blisso_mobile/services/subscriptions/verify_card_details_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class VerifyCardAddress extends ConsumerStatefulWidget {
  const VerifyCardAddress({super.key});

  @override
  ConsumerState<VerifyCardAddress> createState() => _VerifyCardAddressState();
}

class _VerifyCardAddressState extends ConsumerState<VerifyCardAddress> {
  final TextEditingController cityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

  void verifyAddress() async {
    final verifyProvider = ref.read(verifyCardDetailsProviderImpl.notifier);

    final previousRef = ref.read(previousSubscriptionResponseProviderImpl);

    await verifyProvider.verifyCardDetails({
      ...previousRef,
      'authorization': {
        'mode': 'avs_noauth',
        'city': cityController.text,
        'address': addressController.text,
        'state': stateController.text,
        'country': countryController.text,
        'zipcode': zipCodeController.text
      }
    });

    final paymentstate = ref.read(verifyCardDetailsProviderImpl);

    if (paymentstate.statusCode == 200 || paymentstate.statusCode == 201) {
      final subscriptionProvider =
          ref.read(createSubscriptionProviderImpl.notifier);

      final chosenOptions = ref.read(chosenOptionsProviderImpl);

      await subscriptionProvider.createSubscription({
        'plan_code': chosenOptions['code'],
        'price': chosenOptions['amount'],
        'currency': chosenOptions['currency'],
        'transaction_id': paymentstate.data['transaction_id']
      });
      Navigator.of(context).pop();
    } else if (paymentstate.statusCode == 307) {
      final subscriptionProvider =
          ref.read(createSubscriptionProviderImpl.notifier);

      final chosenOptions = ref.read(chosenOptionsProviderImpl);

      await subscriptionProvider.createSubscription({
        'plan_code': chosenOptions['code'],
        'price': chosenOptions['amount'],
        'currency': chosenOptions['currency'],
        'transaction_id': paymentstate.data['transaction_id']
      });

      if (paymentstate.data['validation_mode'] == 'redirect') {
        final encodedURL =
            Uri.encodeComponent(paymentstate.data['redirect_link']);
        Routemaster.of(context)
            .replace('/homepage/webview-complete/$encodedURL');
      }
    } else {
      showSnackBar(context, paymentstate.error!);
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: ExpandableTextComponent(
                    text: 'Verify Billing address of card'),
              ),
              TextInputComponent(
                  controller: cityController,
                  labelText: 'City',
                  hintText: 'Enter your city',
                  validatorFunction: () {}),
              TextInputComponent(
                  controller: addressController,
                  labelText: 'Address',
                  hintText: 'Enter your Address',
                  validatorFunction: () {}),
              TextInputComponent(
                  controller: stateController,
                  labelText: 'State',
                  hintText: 'Enter your state',
                  validatorFunction: () {}),
              TextInputComponent(
                  controller: countryController,
                  labelText: 'Country',
                  hintText: 'Enter your Country',
                  validatorFunction: () {}),
              TextInputComponent(
                  controller: zipCodeController,
                  labelText: 'Zip Code',
                  hintText: 'Enter your Zip Code',
                  validatorFunction: () {}),
              ButtonLoadingComponent(
                  widget: verifyCardDetailsRef.isLoading ||
                          createSubscriptionRef.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Verify Address',
                          style: TextStyle(color: Colors.white),
                        ),
                  backgroundColor: GlobalColors.primaryColor,
                  foregroundColor: GlobalColors.lightBackgroundColor,
                  onTap: verifyAddress)
            ],
          ),
        ),
      ),
    );
  }
}
