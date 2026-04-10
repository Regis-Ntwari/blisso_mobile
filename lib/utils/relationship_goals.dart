import 'package:flutter/material.dart';

class RelationshipGoal {
  final String label;
  final String description;
  final IconData icon;

  const RelationshipGoal({
    required this.label,
    required this.description,
    required this.icon,
  });
}

const List<RelationshipGoal> relationshipGoals = [
  RelationshipGoal(label: 'Life Partner', description: 'Ready for long-term committed, and stable relationship', icon: Icons.auto_awesome_rounded),
  RelationshipGoal(label: 'Long-term', description: 'Serious commitment only', icon: Icons.favorite_rounded),
  RelationshipGoal(label: 'Serious, open to Casual', description: 'Mainly serious vibes', icon: Icons.volunteer_activism_rounded),
  RelationshipGoal(label: 'Casual, open to Serious', description: 'Let\'s see where it goes', icon: Icons.waves_rounded),
  RelationshipGoal(label: 'Short-term Fun', description: 'Nothing heavy, just vibes', icon: Icons.celebration_rounded),
  RelationshipGoal(label: 'New Friends', description: 'Expanding my circle', icon: Icons.people_alt_rounded),
  RelationshipGoal(label: 'Situationship', description: 'Dating without an Official Label', icon: Icons.lock_person_rounded),
  RelationshipGoal(label: 'Friendship with Benefits', description: 'Casual Vibes, No Strings Attached', icon: Icons.all_inclusive_rounded),
  RelationshipGoal(label: 'Sober Dating', description: 'Lifestyle-focused dating', icon: Icons.no_drinks_rounded),
];