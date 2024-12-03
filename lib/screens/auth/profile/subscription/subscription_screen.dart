import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
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

  late final PageController _pageController;
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

  String? _currency = 'RWF';
  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.read(subscriptionServiceProviderImpl);
    TextScaler scaler = MediaQuery.textScalerOf(context);
    double height = MediaQuery.sizeOf(context).height;

    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    return SafeArea(
        child: Scaffold(
      backgroundColor: isLightTheme ? GlobalColors.lightBackgroundColor : null,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Blisso',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: GlobalColors.primaryColor, fontSize: scaler.scale(24)),
        ),
      ),
      body: subscriptionState.isLoading
          ? const LoadingScreen()
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  subscriptionPlans.isEmpty
                      ? const Align(
                          alignment: Alignment.center, child: LoadingScreen())
                      : SizedBox(
                          height: height * 0.8,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Text(
                                    'Choose your plan',
                                    style: TextStyle(
                                        fontSize: scaler.scale(14),
                                        color: GlobalColors.whiteColor),
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.6,
                                  child: PageView.builder(
                                      controller: _pageController,
                                      itemCount: subscriptionPlans.length,
                                      itemBuilder: (ctx, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Stack(
                                            children: [
                                              InkWell(
                                                onTap: () => choosePlan(
                                                    subscriptionPlans[index],
                                                    'RWF',
                                                    1),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color: chosenPlan[
                                                                      'plan_code'] ==
                                                                  subscriptionPlans[
                                                                          index]
                                                                      ['code']
                                                              ? GlobalColors
                                                                  .primaryColor
                                                              : GlobalColors
                                                                  .secondaryColor)),
                                                  height: double.infinity,
                                                  width: double.infinity * 0.75,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text(
                                                        subscriptionPlans[index]
                                                            ['name'],
                                                        style: TextStyle(
                                                            fontSize: scaler
                                                                .scale(24),
                                                            color: GlobalColors
                                                                .primaryColor),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _currency = 'RWF';
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
                                                                    .scale(16)),
                                                          ),
                                                          leading:
                                                              Radio<String>(
                                                            activeColor:
                                                                GlobalColors
                                                                    .primaryColor,
                                                            value: subscriptionPlans[
                                                                            index]
                                                                        [
                                                                        'code'] ==
                                                                    chosenPlan[
                                                                        'plan_code']
                                                                ? 'RWF'
                                                                : '',
                                                            groupValue:
                                                                _currency,
                                                            onChanged: (String?
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
                                                            _currency = 'USD';
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
                                                            value: subscriptionPlans[
                                                                            index]
                                                                        [
                                                                        'code'] ==
                                                                    chosenPlan[
                                                                        'plan_code']
                                                                ? 'USD'
                                                                : '',
                                                            groupValue:
                                                                _currency,
                                                            onChanged: (String?
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
                                                      subscriptionPlans[index]
                                                          ['code']
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
                                      foregroundColor: GlobalColors.whiteColor,
                                      onTap: () async {
                                        await ref
                                            .read(
                                                subscriptionServiceProviderImpl
                                                    .notifier)
                                            .createSubscription(chosenPlan);

                                        final state = ref.read(
                                            subscriptionServiceProviderImpl);

                                        if (state.error != null) {
                                          showSnackBar(context, state.error!);
                                        } else {
                                          Routemaster.of(context)
                                              .replace('/homepage');
                                        }
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
