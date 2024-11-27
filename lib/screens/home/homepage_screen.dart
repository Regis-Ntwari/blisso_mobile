import 'package:blisso_mobile/screens/home/components/post_card_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({super.key});

  static const List<Map<String, dynamic>> photos = [
    {
      'id': 1,
      'photo': 'https://images.unsplash.com/photo-1732639074314-940905792081',
      'username': 'Regis'
    },
    {
      'id': 2,
      'photo': 'https://images.unsplash.com/photo-1611662781749-2d208fec7e44',
      'username': 'Schadrack'
    },
    {
      'id': 3,
      'photo': 'https://images.unsplash.com/photo-1570554634503-9d0f79c97dd5',
      'username': 'Jado'
    },
    {
      'id': 4,
      'photo':
          'https://plus.unsplash.com/premium_photo-1681830320344-6e7a2a8726c3',
      'username': 'Sandrine'
    },
    {
      'id': 5,
      'photo': 'https://images.unsplash.com/photo-1615246445659-ea5716177645',
      'username': 'Michou'
    },
    {
      'id': 6,
      'photo':
          'https://plus.unsplash.com/premium_photo-1723489296114-ec49bd01b017',
      'username': 'Natasha'
    },
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    TextScaler scaler = MediaQuery.textScalerOf(context);
    return SafeArea(
        child: Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              activeIcon: const Icon(
                Icons.home,
                color: GlobalColors.primaryColor,
              ),
              icon: Icon(
                Icons.home,
                color: GlobalColors.secondaryColor,
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              activeIcon: const Icon(
                Icons.home,
                color: GlobalColors.primaryColor,
              ),
              icon: Icon(
                Icons.search,
                color: GlobalColors.secondaryColor,
              ),
              label: 'Search'),
          BottomNavigationBarItem(
              activeIcon: const Icon(
                Icons.home,
                color: GlobalColors.primaryColor,
              ),
              icon: Icon(
                Icons.category,
                color: GlobalColors.secondaryColor,
              ),
              label: 'Explore'),
          BottomNavigationBarItem(
            activeIcon: const Icon(
              Icons.home,
              color: GlobalColors.primaryColor,
            ),
            icon: Icon(
              Icons.person,
              color: GlobalColors.secondaryColor,
            ),
            label: 'Profile',
          )
        ],
        selectedItemColor: GlobalColors.primaryColor,
        selectedLabelStyle: const TextStyle(color: GlobalColors.primaryColor),
        selectedIconTheme:
            const IconThemeData(color: GlobalColors.primaryColor),
      ),
      appBar: AppBar(
        title: Text(
          'Blisso',
          style: TextStyle(
              color: GlobalColors.primaryColor, fontSize: scaler.scale(24)),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications),
          ),
          Padding(
              padding: EdgeInsets.only(right: 20, left: 20),
              child: Icon(Icons.chat)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: PostCardComponent(
                        photo: photos[index]['photo'],
                        username: photos[index]['username']),
                  );
                },
                itemCount: photos.length,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
