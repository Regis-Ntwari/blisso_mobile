import 'package:blisso_mobile/services/profile/update_feeling_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeelingPopupComponent extends ConsumerStatefulWidget {
  const FeelingPopupComponent({super.key});

  @override
  ConsumerState<FeelingPopupComponent> createState() => _FeelingPopupComponentState();
}

class _FeelingPopupComponentState extends ConsumerState<FeelingPopupComponent> {
  final List<Map<String, String>> feelings = [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😠', 'label': 'Angry'},
    {'emoji': '😌', 'label': 'Relaxed'},
  ];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: double.infinity,
              child: Text(
                "How are you feeling?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: GlobalColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: feelings.map((feeling) {
                return GestureDetector(
                  onTap: () async{
                    ref.read(updateFeelingServiceProviderImpl.notifier).updateFeeling(feeling['emoji']!, feeling['label']!);
                    Navigator.of(context).pop();
                  },
                  child: Column(
                    children: [
                      Text(feeling['emoji']!,
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 6),
                      Text(feeling['label']!,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
