import 'package:blisso_mobile/screens/home/components/post_card_component.dart';
import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomepageScreen extends ConsumerStatefulWidget {
  const HomepageScreen({super.key});

  static const List<Map<String, dynamic>> photos = [
    {
      "user": {
        "id": 3,
        "has_profile": true,
        "has_my_snapshots": true,
        "has_target_snapshots": true,
        "has_pictures": true,
        "last_login": null,
        "is_superuser": false,
        "username": "niyibizischadrack05@gmail.com",
        "first_name": "Williams",
        "last_name": "John",
        "is_staff": false,
        "is_active": true,
        "date_joined": "2024-11-29T07:43:35.831443Z",
        "account_deleted": false,
        "accont_deleted_date": null,
        "email": "niyibizischadrack05@gmail.com",
        "auth_type": "EMAIL"
      },
      "id": 3,
      "gender": "male",
      "lang": "English",
      "marital_status": "not to say",
      "show_me": "women",
      "nickname": "John",
      "dob": "1998-02-20",
      "location": "Rwanda, Kigali, Gasabo, Nyabisindu",
      "latitude": "-1.94942150000000000000000000",
      "longitude": "30.10978970000000000000000000",
      "distance_measure": "Km",
      "push_notifications": true,
      "profile_pic":
          "http://40.122.188.22:8000/media/profile/main/niyibizischadrack05gmailcom/1000221666_Ods3sIs.png",
      "hide_profile": false,
      "subscription": {},
      "lifesnapshots": [
        {
          "id": 3,
          "category": "Basic",
          "sub_category": "Education",
          "name": "Physics"
        },
        {
          "id": 4,
          "category": "Lifestyle",
          "sub_category": "Love Style",
          "name": "Affection"
        },
        {
          "id": 5,
          "category": "Basic",
          "sub_category": "Interests",
          "name": "Rock Music"
        },
        {
          "id": 6,
          "category": "Lifestyle",
          "sub_category": "Communication",
          "name": "Chat"
        }
      ],
      "target_lifesnapshots": [
        {
          "id": 3,
          "category": "Basic",
          "sub_category": "Education",
          "name": "Physics",
          "target_scale": 6
        },
        {
          "id": 4,
          "category": "Lifestyle",
          "sub_category": "Love Style",
          "name": "Affection",
          "target_scale": 6
        },
        {
          "id": 5,
          "category": "Basic",
          "sub_category": "Interests",
          "name": "Rock Music",
          "target_scale": 6
        },
        {
          "id": 6,
          "category": "Lifestyle",
          "sub_category": "Communication",
          "name": "Chat",
          "target_scale": 9
        }
      ],
      "profile_images": [
        {
          "profile": 3,
          "id": 5,
          "image":
              "http://40.122.188.22:8000/media/profile/images/current/niyibizischadrack05gmailcom/1000258017.png",
          "added_date": "2024-11-29T07:47:03.815201Z"
        },
        {
          "profile": 3,
          "id": 6,
          "image":
              "http://40.122.188.22:8000/media/profile/images/current/niyibizischadrack05gmailcom/1000221669.png",
          "added_date": "2024-11-29T07:47:03.843193Z"
        },
        {
          "profile": 3,
          "id": 7,
          "image":
              "http://40.122.188.22:8000/media/profile/images/current/niyibizischadrack05gmailcom/1000205875.jpg",
          "added_date": "2024-11-29T07:47:03.855812Z"
        },
        {
          "profile": 3,
          "id": 8,
          "image":
              "http://40.122.188.22:8000/media/profile/images/current/niyibizischadrack05gmailcom/1000205873.jpg",
          "added_date": "2024-11-29T07:47:03.865650Z"
        }
      ],
      "profile_locations": [
        {
          "profile": 3,
          "id": 3,
          "location": "Rwanda, Kigali, Gasabo, Nyabisindu",
          "latitude": "-1.94942150000000000000000000",
          "longitude": "30.10978970000000000000000000",
          "location_datetime": "2024-11-29T07:45:24.284897Z"
        }
      ],
      "distance": 15153.8,
      "distance_annot": "15153.8 Km",
      "age": 26,
      "permissions": {
        "can_view": true,
        "can_view_detail": true,
        "can_send_message_request": false
      }
    },
    {
      "user": {
        "id": 2,
        "has_profile": true,
        "has_my_snapshots": true,
        "has_target_snapshots": true,
        "has_pictures": true,
        "last_login": null,
        "is_superuser": false,
        "username": "regis.ntwari.danny@gmail.com",
        "first_name": "Regis",
        "last_name": "Ntwari",
        "is_staff": false,
        "is_active": true,
        "date_joined": "2024-11-27T13:52:07.200686Z",
        "account_deleted": false,
        "accont_deleted_date": null,
        "email": "regis.ntwari.danny@gmail.com",
        "auth_type": "EMAIL"
      },
      "id": 2,
      "gender": "male",
      "lang": "English",
      "marital_status": "not to say",
      "show_me": "women",
      "nickname": "Regis",
      "dob": "2000-12-12",
      "location": "Rwanda, Kigali, Nyarugenge, Kiyovu",
      "latitude": "-1.94228860000000000000000000",
      "longitude": "30.05815210000000000000000000",
      "distance_measure": "Km",
      "push_notifications": true,
      "profile_pic":
          "http://40.122.188.22:8000/media/profile/main/regisntwaridannygmailcom/1000827131.jpg",
      "hide_profile": false,
      "subscription": {
        "plan_code": "002",
        "plan_name": "Monthly Plan",
        "price": 5000.0,
        "currency": "RWF",
        "start_date": "2024-12-02 07:13:09",
        "end_date": "2025-01-01 07:13:09"
      },
      "lifesnapshots": [
        {
          "id": 1,
          "category": "Basic",
          "sub_category": "Education",
          "name": "Physics"
        },
        {
          "id": 2,
          "category": "Basic",
          "sub_category": "Interests",
          "name": "Rock Music"
        }
      ],
      "target_lifesnapshots": [
        {
          "id": 1,
          "category": "Basic",
          "sub_category": "Education",
          "name": "Physics",
          "target_scale": 4
        },
        {
          "id": 2,
          "category": "Lifestyle",
          "sub_category": "Love Style",
          "name": "Affection",
          "target_scale": 8
        }
      ],
      "profile_images": [
        {
          "profile": 2,
          "id": 1,
          "image":
              "http://40.122.188.22:8000/media/profile/images/current/regisntwaridannygmailcom/1000827223.jpg",
          "added_date": "2024-11-27T13:56:48.362333Z"
        },
        {
          "profile": 2,
          "id": 2,
          "image":
              "http://40.122.188.22:8000/media/profile/images/current/regisntwaridannygmailcom/a118465e-41fc-47a2-8538-33cc7be472051295_z3ciqlt.jpg",
          "added_date": "2024-11-27T13:56:48.378860Z"
        },
        {
          "profile": 2,
          "id": 3,
          "image":
              "http://40.122.188.22:8000/media/profile/images/current/regisntwaridannygmailcom/1000826092.jpg",
          "added_date": "2024-11-27T13:56:48.389546Z"
        },
        {
          "profile": 2,
          "id": 4,
          "image":
              "http://40.122.188.22:8000/media/profile/images/current/regisntwaridannygmailcom/1000826986.jpg",
          "added_date": "2024-11-27T13:56:48.399164Z"
        }
      ],
      "profile_locations": [
        {
          "profile": 2,
          "id": 2,
          "location": "Rwanda, Kigali, Nyarugenge, Kiyovu",
          "latitude": "-1.94228860000000000000000000",
          "longitude": "30.05815210000000000000000000",
          "location_datetime": "2024-11-27T13:53:37.507226Z"
        }
      ],
      "distance": 15150.05,
      "distance_annot": "15150.05 Km",
      "age": 24,
      "permissions": {
        "can_view": true,
        "can_view_detail": true,
        "can_send_message_request": false
      }
    },
  ];

  @override
  ConsumerState<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends ConsumerState<HomepageScreen> {
  Future<void> getProfiles() async {
    final state = ref.read(profileServiceProviderImpl.notifier);

    await state.getAllProfiles();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLightTheme ? GlobalColors.lightBackgroundColor : null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: BottomNavigationBar(
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
            child: Column(
              children: [
                SizedBox(
                  height: height,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: kBottomNavigationBarHeight),
                        child: PostCardComponent(
                          profile: HomepageScreen.photos[index],
                        ),
                      );
                    },
                    itemCount: HomepageScreen.photos.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
