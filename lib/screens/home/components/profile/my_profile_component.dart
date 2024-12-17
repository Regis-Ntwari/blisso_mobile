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
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
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
            InkWell(
              onTap: () {},
              child: const ListTile(
                title: Text('Make changes'),
                subtitle: Text('Click to change your profile'),
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
            ),
            InkWell(
              onTap: () {},
              child: const ListTile(
                title: Text('Make changes'),
                subtitle: Text('Click to change your profile'),
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
            ),
            InkWell(
              onTap: () {},
              child: const ListTile(
                title: Text('Make changes'),
                subtitle: Text('Click to change your profile'),
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
            )
          ],
        ),
      ),
    );
  }
}
