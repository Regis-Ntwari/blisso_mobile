import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class MyProfileComponent extends StatefulWidget {
  const MyProfileComponent({super.key});

  @override
  State<MyProfileComponent> createState() => _MyProfileComponentState();
}

class _MyProfileComponentState extends State<MyProfileComponent> {
  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                        'http://40.122.188.22:8000//media/profile/main/niyibizischadrack05gmailcom/1000221666_Ods3sIs.png'),
                    radius: 100,
                  ),
                ],
              ),
            ),
            Text(
              'Schadrack Niyibizi',
              style: TextStyle(
                  fontSize: scaler.scale(16), fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text('Make changes'),
            )
          ],
        ),
      ),
    );
  }
}
