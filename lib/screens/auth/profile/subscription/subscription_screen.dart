import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/screens/auth/profile/subscription/modes/payment_modes.dart';
import 'package:blisso_mobile/screens/auth/profile/subscription/payment/card_payment.dart';
import 'package:blisso_mobile/screens/auth/profile/subscription/verification/billing_verification.dart';
import 'package:blisso_mobile/screens/auth/profile/subscription/verification/pin_verification.dart';
import 'package:blisso_mobile/services/models/initiate_payment_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  List<dynamic> subscriptionPlans = [];

  Map<String, dynamic> chosenPlan = {};

  final TextEditingController cvv = TextEditingController();

  final TextEditingController cardNumber = TextEditingController();

  final TextEditingController expirationDate = TextEditingController();

  final TextEditingController cardNames = TextEditingController();

  final TextEditingController city = TextEditingController();

  final TextEditingController state = TextEditingController();

  final TextEditingController country = TextEditingController();

  final TextEditingController zipCode = TextEditingController();

  final TextEditingController address = TextEditingController();

  final TextEditingController otpController = TextEditingController();

  dynamic paymentResponse;

  late final PageController _pageController;

  bool isSubscriptionCreated = false;

  InitiatePaymentModel? paymentModel;
  Future<void> getSubscriptionPlans() async {
    final subscriptionState =
        ref.read(subscriptionServiceProviderImpl.notifier);

    await subscriptionState.getSubscriptionPlans();

    final response = ref.watch(subscriptionServiceProviderImpl);

    setState(() {
      subscriptionPlans = response.data;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSubscriptionPlans();
    });

    _pageController = PageController(initialPage: 0, viewportFraction: 0.75);

    expirationDate.addListener(() {
      final text = expirationDate.text;

      // Add slash after entering month
      if (text.length == 2 && !text.contains('/')) {
        expirationDate.value = TextEditingValue(
          text: '$text/',
          selection: const TextSelection.collapsed(offset: 3),
        );
      }
    });
  }

  void verifyAddress() async {
    paymentModel!.authorization!['city'] = city.text;
    paymentModel!.authorization!['address'] = address.text;
    paymentModel!.authorization!['state'] = state.text;
    paymentModel!.authorization!['country'] = country.text;
    paymentModel!.authorization!['zipcode'] = zipCode.text;

    final verifyProvider = ref.read(subscriptionServiceProviderImpl.notifier);

    await verifyProvider.verifyCardDetails(paymentModel!);

    final paymentstate = ref.read(subscriptionServiceProviderImpl);

    if (paymentstate.statusCode == 200 || paymentstate.statusCode == 201) {
      final subscriptionProvider =
          ref.read(subscriptionServiceProviderImpl.notifier);

      chosenPlan['transaction_id'] = paymentstate.data['transaction_id'];

      await subscriptionProvider.createSubscription(chosenPlan);

      setState(() {
        isSubscriptionCreated = true;
      });

      Navigator.of(context).pop();
      Routemaster.of(context).replace('/homepage');
    } else if (paymentstate.statusCode == 307) {
      final subscriptionProvider =
          ref.read(subscriptionServiceProviderImpl.notifier);

      chosenPlan['transaction_id'] = paymentstate.data['transaction_id'];

      await subscriptionProvider.createSubscription(chosenPlan);

      setState(() {
        isSubscriptionCreated = true;
      });

      Navigator.of(context).pop();

      if (paymentstate.data['validation_mode'] == 'redirect') {
        final encodedURL =
            Uri.encodeComponent(paymentstate.data['redirect_link']);
        Routemaster.of(context).push('/webview-complete/$encodedURL');
      }
    } else {
      showSnackBar(context, paymentstate.error!);
    }
  }

  void verifyPin() async {
    paymentModel!.authorization!['pin'] = otpController.text;

    final verifyProvider = ref.read(subscriptionServiceProviderImpl.notifier);

    await verifyProvider.verifyCardDetails(paymentModel!);

    final paymentState = ref.read(subscriptionServiceProviderImpl);

    if (paymentState.statusCode == 200 || paymentState.statusCode == 201) {
      final subscriptionProvider =
          ref.read(subscriptionServiceProviderImpl.notifier);

      chosenPlan['transaction_id'] = paymentState.data['transaction_id'];

      await subscriptionProvider.createSubscription(chosenPlan);

      setState(() {
        isSubscriptionCreated = true;
      });

      Navigator.of(context).pop();
      Routemaster.of(context).replace('/homepage');
    } else if (paymentState.statusCode == 307) {
      final subscriptionProvider =
          ref.read(subscriptionServiceProviderImpl.notifier);

      chosenPlan['transaction_id'] = paymentState.data['transaction_id'];

      await subscriptionProvider.createSubscription(chosenPlan);

      setState(() {
        isSubscriptionCreated = true;
      });

      Navigator.of(context).pop();
      Routemaster.of(context).replace('/homepage');
    } else {
      showSnackBar(context, paymentState.error!);
    }
  }

  void choosePlan(Map<String, dynamic> plan, String currency, double months) {
    var clickedPlan = {
      'plan_code': plan['code'],
      'price': currency == 'RWF' ? plan['rw_price'] : plan['usd_price'],
      'currency': currency
    };
    setState(() {
      chosenPlan = clickedPlan;
    });
  }

  void initiatePayment() async {
    String email = await SharedPreferencesService.getPreference('username');

    var payment = InitiatePaymentModel(
      cardNumber: cardNumber.text,
      expiryMonth: expirationDate.text.split('/')[0],
      expiryYear: expirationDate.text.split('/')[1],
      cvv: cvv.text,
      currency: chosenPlan['currency'],
      amount: chosenPlan['price'].toString(),
      fullname: cardNames.text,
      email: email,
    );

    final paymentProvider = ref.read(subscriptionServiceProviderImpl.notifier);

    await paymentProvider.initiatePayment(payment);

    final paymentState = ref.read(subscriptionServiceProviderImpl);

    if (paymentState.statusCode == 307) {
      setState(() {
        paymentModel =
            InitiatePaymentModel.fromFirstResponse(paymentState.data);
      });
      if (paymentModel!.authorizationMode == 'avs_noauth') {
        Navigator.of(context).pop();
        showBillingVerification(
            city: city,
            address: address,
            state: state,
            country: country,
            zipCode: zipCode,
            verifyAddress: verifyAddress,
            context: context);
      } else {
        Navigator.of(context).pop();
        showPinVerification(
            context: context,
            otpController: otpController,
            verifyPin: verifyPin);
      }
    } else if (paymentState.statusCode == 200 ||
        paymentState.statusCode == 201) {
      final subscriptionProvider =
          ref.read(subscriptionServiceProviderImpl.notifier);

      chosenPlan['transaction_id'] = paymentState.data['transaction_id'];

      await subscriptionProvider.createSubscription(chosenPlan);

      setState(() {
        isSubscriptionCreated = true;
      });

      Routemaster.of(context).replace('/homepage');
    } else {
      showSnackBar(context, paymentState.error!);
    }
  }

  String? _currency = 'RWF';

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionServiceProviderImpl);
    TextScaler scaler = MediaQuery.textScalerOf(context);
    double height = MediaQuery.sizeOf(context).height;

    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    isSubscriptionCreated ? Routemaster.of(context).replace('/homepage') : null;

    return SafeArea(
        child: subscriptionState.isLoading || subscriptionPlans.isEmpty
            ? const LoadingScreen()
            : Scaffold(
                backgroundColor: isLightTheme
                    ? GlobalColors.lightBackgroundColor
                    : Colors.black,
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    'Blisso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: GlobalColors.primaryColor,
                        fontSize: scaler.scale(24)),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      subscriptionPlans.isEmpty
                          ? const Align(
                              alignment: Alignment.center,
                              child: LoadingScreen())
                          : SizedBox(
                              height: height * 0.8,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: Text(
                                        'Choose your plan',
                                        style: TextStyle(
                                          fontSize: scaler.scale(14),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * 0.6,
                                      child: PageView.builder(
                                          controller: _pageController,
                                          itemCount: subscriptionPlans.length,
                                          itemBuilder: (ctx, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Stack(
                                                children: [
                                                  InkWell(
                                                    onTap: () => choosePlan(
                                                        subscriptionPlans[
                                                            index],
                                                        'RWF',
                                                        1),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              color: chosenPlan[
                                                                          'plan_code'] ==
                                                                      subscriptionPlans[
                                                                              index]
                                                                          [
                                                                          'code']
                                                                  ? GlobalColors
                                                                      .primaryColor
                                                                  : GlobalColors
                                                                      .secondaryColor)),
                                                      height: double.infinity,
                                                      width: double.infinity *
                                                          0.75,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Text(
                                                            subscriptionPlans[
                                                                index]['name'],
                                                            style: TextStyle(
                                                                fontSize: scaler
                                                                    .scale(24),
                                                                color: GlobalColors
                                                                    .primaryColor),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                _currency =
                                                                    'RWF';
                                                                choosePlan(
                                                                    subscriptionPlans[
                                                                        index],
                                                                    _currency!,
                                                                    1);
                                                              });
                                                            },
                                                            child: ListTile(
                                                              title: Text(
                                                                '${subscriptionPlans[index]["rw_price"]} RWF',
                                                                style: TextStyle(
                                                                    fontSize: scaler
                                                                        .scale(
                                                                            16)),
                                                              ),
                                                              leading:
                                                                  Radio<String>(
                                                                activeColor:
                                                                    GlobalColors
                                                                        .primaryColor,
                                                                value: subscriptionPlans[index]
                                                                            [
                                                                            'code'] ==
                                                                        chosenPlan[
                                                                            'plan_code']
                                                                    ? 'RWF'
                                                                    : '',
                                                                groupValue:
                                                                    _currency,
                                                                onChanged:
                                                                    (String?
                                                                        value) {
                                                                  setState(() {
                                                                    _currency =
                                                                        value;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                _currency =
                                                                    'USD';
                                                                choosePlan(
                                                                    subscriptionPlans[
                                                                        index],
                                                                    _currency!,
                                                                    1);
                                                              });
                                                            },
                                                            child: ListTile(
                                                              title: Text(
                                                                  '${subscriptionPlans[index]['usd_price']} USD'),
                                                              leading:
                                                                  Radio<String>(
                                                                activeColor:
                                                                    GlobalColors
                                                                        .primaryColor,
                                                                value: subscriptionPlans[index]
                                                                            [
                                                                            'code'] ==
                                                                        chosenPlan[
                                                                            'plan_code']
                                                                    ? 'USD'
                                                                    : '',
                                                                groupValue:
                                                                    _currency,
                                                                onChanged:
                                                                    (String?
                                                                        value) {
                                                                  setState(() {
                                                                    _currency =
                                                                        value;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  chosenPlan['plan_code'] ==
                                                          subscriptionPlans[
                                                              index]['code']
                                                      ? const Positioned(
                                                          right: 0,
                                                          child: Icon(
                                                            Icons.verified,
                                                            color: GlobalColors
                                                                .primaryColor,
                                                            size: 50,
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              ),
                                            );
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: ButtonComponent(
                                          text: 'Submit',
                                          backgroundColor:
                                              GlobalColors.primaryColor,
                                          foregroundColor:
                                              GlobalColors.whiteColor,
                                          onTap: () async {
                                            if (_currency == 'RWF') {
                                              showPaymentModes(
                                                  context: context,
                                                  payByCard: () {
                                                    Navigator.of(context).pop();

                                                    showCardPayment(
                                                        context: context,
                                                        cardNames: cardNames,
                                                        cardNumber: cardNumber,
                                                        expirationDate:
                                                            expirationDate,
                                                        cvv: cvv,
                                                        initiatePayment:
                                                            initiatePayment);
                                                  },
                                                  payByMomo: () {
                                                    Navigator.of(context).pop();

                                                    showCardPayment(
                                                        context: context,
                                                        cardNames: cardNames,
                                                        cardNumber: cardNumber,
                                                        expirationDate:
                                                            expirationDate,
                                                        cvv: cvv,
                                                        initiatePayment:
                                                            initiatePayment);
                                                  });

                                              // Navigator.of(context).pop();
                                              // if (paymentModel!
                                              //         .authorizationMode ==
                                              //     'avs') {
                                              //   showBillingVerification(
                                              //       city: city,
                                              //       address: address,
                                              //       state: state,
                                              //       country: country,
                                              //       zipCode: zipCode,
                                              //       verifyAddress:
                                              //           verifyAddress,
                                              //       context: context);
                                              // } else {
                                              //   showPinVerification(
                                              //       context: context,
                                              //       otpController:
                                              //           otpController,
                                              //       verifyPin: verifyPin);
                                              // }
                                            } else {
                                              // usd payment
                                              showPaymentModes(
                                                  context: context,
                                                  isMomoEnabled: false,
                                                  payByCard: () {
                                                    Navigator.of(context).pop();

                                                    showCardPayment(
                                                        context: context,
                                                        cardNames: cardNames,
                                                        cardNumber: cardNumber,
                                                        expirationDate:
                                                            expirationDate,
                                                        cvv: cvv,
                                                        initiatePayment:
                                                            initiatePayment);
                                                  },
                                                  payByMomo: () {
                                                    Navigator.of(context).pop();

                                                    showCardPayment(
                                                        context: context,
                                                        cardNames: cardNames,
                                                        cardNumber: cardNumber,
                                                        expirationDate:
                                                            expirationDate,
                                                        cvv: cvv,
                                                        initiatePayment:
                                                            initiatePayment);
                                                  });
                                            }

                                            // final state = ref.read(
                                            //     subscriptionServiceProviderImpl);

                                            // if (state.error != null) {
                                            //   showSnackBar(context, state.error!);
                                            // } else {
                                            //   Routemaster.of(context)
                                            //       .replace('/homepage');
                                            // }
                                          }),
                                    )
                                  ],
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              ));
  }
}
