import 'package:blisso_mobile/screens/home/components/post_card_component.dart';
import 'package:blisso_mobile/screens/home/components/short_status_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class HomeComponent extends StatelessWidget {
  final List<dynamic> profiles;
  final Map<String, List<dynamic>> stories;

  const HomeComponent({
    super.key,
    required this.profiles,
    required this.stories,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final bool hasProfiles = profiles.isNotEmpty;

    return Column(
      children: [
        ShortStatusComponent(statuses: stories),
        const SizedBox(height: 8),

        // Posts / profiles section
        if (hasProfiles)
          ...profiles.map((profile) => PostCardComponent(profile: profile))
        else
          _EmptyPostsFeed(isLightTheme: isLightTheme),
      ],
    );
  }
}

class _EmptyPostsFeed extends StatelessWidget {
  final bool isLightTheme;

  const _EmptyPostsFeed({required this.isLightTheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GlobalColors.primaryColor.withOpacity(0.08),
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: GlobalColors.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your feed is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLightTheme ? Colors.black87 : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Profiles will\nappear here. Start exploring!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isLightTheme ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              // Bubble up to HomepageScreen to switch to the Match tab (index 1)
              // You can replace this with your navigation logic, e.g.:
              // Routemaster.of(context).push('/homepage/matching');
            },
            icon: const Icon(Icons.explore_outlined),
            label: const Text('Explore Matches'),
            style: OutlinedButton.styleFrom(
              foregroundColor: GlobalColors.primaryColor,
              side: BorderSide(color: GlobalColors.primaryColor),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}