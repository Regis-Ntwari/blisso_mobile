import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/services/profile/my_profile_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyProfileComponent extends ConsumerStatefulWidget {
  const MyProfileComponent({super.key});

  @override
  ConsumerState<MyProfileComponent> createState() => _MyProfileComponentState();
}

class _MyProfileComponentState extends ConsumerState<MyProfileComponent> {
  String firstname = '';
  String lastname = '';
  String profilePicture = '';
  String expandedField = '';
  Future<void> getNames() async {
    await SharedPreferencesService.getPreference('firstname').then((value) {
      setState(() {
        firstname = value!;
      });
    });

    await SharedPreferencesService.getPreference('lastname').then((value) {
      setState(() {
        lastname = value!;
      });
    });

    await SharedPreferencesService.getPreference('profile_picture')
        .then((value) {
      setState(() {
        profilePicture = value!;
      });
    });
  }

  Future<void> fetchMyProfile() async {
    final profileState = ref.read(myProfileServiceProviderImpl.notifier);

    await profileState.getMyProfile();
  }

  @override
  void initState() {
    super.initState();
    getNames();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final profileState = ref.watch(myProfileServiceProviderImpl);
    return SafeArea(
      child: Scaffold(
        body: profileState.isLoading || profileState.data == null
            ? const LoadingScreen()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 5),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                CircleAvatar(
                                  backgroundImage: profilePicture == ''
                                      ? const AssetImage(
                                          'assets/images/avatar1.jpg')
                                      : CachedNetworkImageProvider(
                                          profilePicture,
                                        ),
                                  radius: 50,
                                ),
                                Text(
                                  '$firstname $lastname',
                                  style: TextStyle(
                                      fontSize: scaler.scale(10),
                                      color: GlobalColors.secondaryColor),
                                ),
                                Text(
                                  '${profileState.data['user']['email']}',
                                  style: TextStyle(
                                      fontSize: scaler.scale(10),
                                      color: GlobalColors.secondaryColor),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Wrap(children: [
                                  const Text(
                                    'Nickname: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(profileState.data['nickname']),
                                ]),
                                Wrap(children: [
                                  const Text(
                                    'Language: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(profileState.data['lang']),
                                ]),
                                Wrap(children: [
                                  const Text(
                                    'Date of Birth: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(profileState.data['dob']),
                                ]),
                                Wrap(children: [
                                  const Text(
                                    'Gender: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(profileState.data['gender']),
                                ]),
                                Wrap(children: [
                                  const Text(
                                    'Marital Status: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(profileState.data['marital_status']),
                                ]),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Column(
                        children: [
                          SizedBox(
                              height: 150,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: profileState
                                      .data['profile_images'].length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: CachedNetworkImage(
                                            imageUrl: profileState
                                                    .data['profile_images']
                                                [index]['image_uri']),
                                      ),
                                    );
                                  },
                                ),
                              )),
                          InkWell(
                            onTap: () {
                              if (expandedField == 'interest') {
                                setState(() {
                                  expandedField = '';
                                });
                              } else {
                                setState(() {
                                  expandedField = 'interest';
                                });
                              }
                            },
                            child: ListTile(
                              title: const Text(
                                'My Interests',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  '${profileState.data['lifesnapshots'].map((snapshot) => snapshot['name']).join(", ")}'),
                              trailing: expandedField == 'interest'
                                  ? const Icon(Icons.keyboard_arrow_down)
                                  : const Icon(Icons.keyboard_arrow_right),
                            ),
                          ),
                          if (expandedField == 'interest')
                            SingleChildScrollView(
                              child: Wrap(
                                children: profileState.data['lifesnapshots']
                                    .map<Widget>((snapshot) {
                                  return ListTile(
                                    title: Text(snapshot['name']),
                                    trailing: const Icon(
                                      Icons.delete,
                                      color: GlobalColors.primaryColor,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          InkWell(
                            onTap: () {
                              if (expandedField == 'target') {
                                setState(() {
                                  expandedField = '';
                                });
                              } else {
                                setState(() {
                                  expandedField = 'target';
                                });
                              }
                            },
                            child: ListTile(
                              title: const Text('What you wish in a person',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${profileState.data['target_lifesnapshots'].map((snapshot) => snapshot['name']).join(", ")}'),
                              trailing: expandedField == 'target'
                                  ? const Icon(Icons.keyboard_arrow_down)
                                  : const Icon(Icons.keyboard_arrow_right),
                            ),
                          ),
                          if (expandedField == 'target')
                            SingleChildScrollView(
                              child: Wrap(
                                children: profileState
                                    .data['target_lifesnapshots']
                                    .map<Widget>((snapshot) {
                                  return ListTile(
                                    title: Text(snapshot['name']),
                                    trailing: const Icon(
                                      Icons.delete,
                                      color: GlobalColors.primaryColor,
                                    ),
                                  );
                                }).toList(),
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
                  ],
                ),
              ),
      ),
    );
  }
}
