import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class FavoriteProfileScreen extends StatefulWidget {
  final String profileUsername;
  const FavoriteProfileScreen({super.key, required this.profileUsername});

  @override
  State<FavoriteProfileScreen> createState() => _FavoriteProfileScreenState();
}

class _FavoriteProfileScreenState extends State<FavoriteProfileScreen> {
  Map<String, dynamic> get profile {
    return {};
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Blisso',
          style: TextStyle(
              fontSize: scaler.scale(18), color: GlobalColors.primaryColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: profile['profile_pic'],
                radius: 50,
              )
            ],
          ),
        ),
      ),
    ));
  }
}
