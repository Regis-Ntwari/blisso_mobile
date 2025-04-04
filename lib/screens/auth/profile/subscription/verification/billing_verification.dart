import 'package:blisso_mobile/components/button_loading_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BillingVerification extends ConsumerWidget {
  final TextEditingController cityController;
  final TextEditingController addressController;
  final TextEditingController stateController;
  final TextEditingController countryController;
  final TextEditingController zipCodeController;
  final Function verifyAddress;
  const BillingVerification(
      {super.key,
      required this.addressController,
      required this.cityController,
      required this.countryController,
      required this.stateController,
      required this.verifyAddress,
      required this.zipCodeController});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionServiceProviderImpl);
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Provide your address as verification'),
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
                    widget: subscriptionState.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.black,
                          )
                        : const Text('Verify'),
                    backgroundColor: GlobalColors.primaryColor,
                    foregroundColor: GlobalColors.lightBackgroundColor,
                    onTap: () => verifyAddress())
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showBillingVerification(
    {required TextEditingController city,
    required TextEditingController address,
    required TextEditingController state,
    required TextEditingController country,
    required TextEditingController zipCode,
    required Function verifyAddress,
    required BuildContext context}) {
  showDialog(
    context: context,
    builder: (context) {
      return BillingVerification(
          addressController: address,
          cityController: city,
          countryController: country,
          stateController: state,
          verifyAddress: verifyAddress,
          zipCodeController: zipCode);
    },
  );
}
