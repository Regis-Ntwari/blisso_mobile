import 'package:blisso_mobile/screens/home/components/post_card_component.dart';
import 'package:blisso_mobile/screens/home/components/short_status_component.dart';
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
    return Column(
      children: [
        ShortStatusComponent(statuses: stories),
        ...profiles.map(
          (profile) => PostCardComponent(profile: profile),
        ),
      ],
    );
  }
}
