import 'package:blisso_mobile/components/button_loading_component.dart';
import 'package:blisso_mobile/components/expandable_text_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/screens/utils/subscription/chosen_options_provider.dart';
import 'package:blisso_mobile/screens/utils/subscription/previous_subscription_response_provider.dart';
import 'package:blisso_mobile/services/models/initiate_payment_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/subscriptions/create_subscription_service_provider.dart';
import 'package:blisso_mobile/services/subscriptions/initiate_payment_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class CardFormSubscription extends ConsumerStatefulWidget {
  const CardFormSubscription({super.key});

  @override
  ConsumerState<CardFormSubscription> createState() =>
      _CardFormSubscriptionState();
}

class _CardFormSubscriptionState extends ConsumerState<CardFormSubscription> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController cardNames = TextEditingController();
  TextEditingController cardNumber = TextEditingController();
  TextEditingController expirationDate = TextEditingController();
  TextEditingController cvv = TextEditingController();

  void initiatePayment() async {
    String email = await SharedPreferencesService.getPreference('username');

    final chosenOptionState = ref.read(chosenOptionsProviderImpl);

    var payment = InitiatePaymentModel(
      cardNumber: cardNumber.text,
      expiryMonth: expirationDate.text.split('/')[0],
      expiryYear: expirationDate.text.split('/')[1],
      cvv: cvv.text,
      currency: chosenOptionState['currency'],
      amount: chosenOptionState['amount'].toString(),
      fullname: cardNames.text,
      email: email,
    );

    final paymentProvider =
        ref.read(initiatePaymentServiceProviderImpl.notifier);

    await paymentProvider.initiatePayment(payment);

    final paymentState = ref.read(initiatePaymentServiceProviderImpl);

    if (paymentState.statusCode == 307 &&
        paymentState.data['authorization']['mode'] == 'avs_noauth') {
          final chosenRef = ref.read(previousSubscriptionResponseProviderImpl.notifier);
          chosenRef.resetOptions();
          chosenRef.addWholeMap(paymentState.data);
          Routemaster.of(context).replace('/homepage/verify-card-address');
      
    } else if (paymentState.statusCode == 307 &&
        paymentState.data['authorization']['mode'] == 'pin') {
          final chosenRef = ref.read(previousSubscriptionResponseProviderImpl.notifier);
          chosenRef.resetOptions();
          chosenRef.addWholeMap(paymentState.data);
          Routemaster.of(context).replace('/homepage/verify-card-pin');
      
    } else if (paymentState.statusCode == 200 ||
        paymentState.statusCode == 201) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final initRef = ref.watch(initiatePaymentServiceProviderImpl);
    final createRef = ref.watch(createSubscriptionProviderImpl);
    return SafeArea(
        child: Scaffold(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isLightTheme ? Colors.white : Colors.black,
        title: const Text('Card Payment'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.keyboard_arrow_left)),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: ExpandableTextComponent(
                        text: 'Please Provide your card details'),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ButtonLoadingComponent(
                        widget: initRef.isLoading || createRef.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Pay',
                                style: TextStyle(color: Colors.white),
                              ),
                        backgroundColor: GlobalColors.primaryColor,
                        foregroundColor: GlobalColors.whiteColor,
                        onTap: initiatePayment),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
