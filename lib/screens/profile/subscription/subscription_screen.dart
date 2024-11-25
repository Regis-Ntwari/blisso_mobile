import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  List<dynamic> subscriptionPlans = [];
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
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.read(subscriptionServiceProviderImpl);
    TextScaler scaler = MediaQuery.textScalerOf(context);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Blisso',
          style: TextStyle(
              color: GlobalColors.primaryColor, fontSize: scaler.scale(16)),
        ),
      ),
      body: subscriptionState.isLoading
          ? const LoadingScreen()
          : SingleChildScrollView(
              child: Column(
                children: [
                  subscriptionPlans.isEmpty
                      ? const LoadingScreen()
                      : ListView.builder(
                          itemBuilder: (BuildContext ctx, int index) {
                            return Card();
                          },
                          itemCount: subscriptionPlans.length,
                        )
                ],
              ),
            ),
    ));
  }
}
