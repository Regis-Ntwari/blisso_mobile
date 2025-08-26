import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class SubscriptionDesign extends StatelessWidget {
  bool isActive;
  final String title;
  final bool isChat;
  final bool postStory;
  final bool viewStory;
  final bool viewStoryCaption;
  final bool postVideos;
  final bool viewRecommendations;
  final bool viewProfiles;
  final bool viewVideos;
  final bool viewVideoCaption;
  final bool shareProfile;
  final bool shareVideos;
  SubscriptionDesign(
      {super.key,
      required this.title,
      required this.isChat,
      this.isActive = false,
      required this.postStory,
      required this.viewStory,
      required this.viewStoryCaption,
      required this.postVideos,
      required this.viewRecommendations,
      required this.viewProfiles,
      required this.viewVideos,
      required this.viewVideoCaption,
      required this.shareProfile,
      required this.shareVideos});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return Stack(
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: width * 0.9),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title and Subtitle
                  Text(
                    'Blisso $title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: GlobalColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Features offered by this plan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Feature Comparison Table
                  FeatureRow(
                    feature: 'Chat',
                    value: isChat,
                  ),
                  FeatureRow(
                    feature: 'Post story',
                    value: postStory,
                  ),
                  FeatureRow(
                    feature: 'View story',
                    value: viewStory,
                  ),
                  FeatureRow(
                    feature: 'View story caption',
                    value: viewStoryCaption,
                  ),
                  FeatureRow(
                    feature: 'Post videos',
                    value: postVideos,
                  ),
                  FeatureRow(
                    feature: 'View recommendations',
                    value: viewRecommendations,
                  ),
                  FeatureRow(
                    feature: 'View profiles',
                    value: viewProfiles,
                  ),
                  FeatureRow(
                    feature: 'View videos',
                    value: viewVideos,
                  ),
                  FeatureRow(
                    feature: 'View video caption',
                    value: viewVideoCaption,
                  ),
                  FeatureRow(
                    feature: 'Share profile',
                    value: shareProfile,
                  ),
                  FeatureRow(
                    feature: 'Share videos',
                    value: shareVideos,
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GlobalColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Go ${isChat ? 'Premium' : 'Free'}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          color: GlobalColors.primaryColor,
          child: const Text(
            'Active',
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ))
      ],
    );
  }
}

class FeatureRow extends StatelessWidget {
  final String feature;
  final bool value;

  const FeatureRow({
    super.key,
    required this.feature,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: Icon(
              value ? Icons.check : Icons.close,
              color: value ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
