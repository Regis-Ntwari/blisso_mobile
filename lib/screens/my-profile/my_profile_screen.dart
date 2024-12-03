import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
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
          child: Column(
            children: [CircleAvatar()],
          ),
        ),
      ),
    );
  }
}
