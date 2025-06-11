import 'dart:io';

import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/components/view_picture_component.dart';
import 'package:blisso_mobile/screens/home/components/profile/edit_my_profile_component.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/my_profile_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service_provider.dart';
import 'package:blisso_mobile/services/video-post/video_post_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MyProfileComponent extends ConsumerStatefulWidget {
  const MyProfileComponent({super.key});

  @override
  ConsumerState<MyProfileComponent> createState() => _MyProfileComponentState();
}

class _MyProfileComponentState extends ConsumerState<MyProfileComponent>
    with AutomaticKeepAliveClientMixin {
  String firstname = '';
  String lastname = '';
  String profilePicture = '';
  String expandedField = '';
  File? chosenPicture;
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

  void updateChosenPicture(File? file) {
    setState(() {
      chosenPicture = file;
    });
  }

  Future<void> replaceImage(Map<String, dynamic> image) async {
    final profileRef = ref.read(myProfileServiceProviderImpl.notifier);

    await profileRef.replaceImage(chosenPicture!, image['id']);

    final profileState = ref.read(myProfileServiceProviderImpl);

    if (profileState.error == null) {
      Navigator.of(context).pop();

      await profileRef.getMyProfile();
    } else {
      showSnackBar(context, profileState.error!);
    }
  }

  List<Map<String, dynamic>> subscriptions = [
    {
      "plan_code": "001",
      "plan_name": "Free plan",
      "price": 0,
      "currency": "RWF",
      "rw_price": 0,
      "usd_price": 0.0,
      "start_date": "2024-11-09 14:32:08",
      "end_date": "2027-10-25 14:32:08",
      "expired": false
    },
    {
      "plan_code": "002",
      "plan_name": "Monthly plan",
      "price": 5000,
      "currency": "RWF",
      "rw_price": 5000,
      "usd_price": 5.0,
      "start_date": "2024-11-09 19:00:34",
      "end_date": "2024-12-09 19:00:34",
      "expired": false
    }
  ];

  Future<void> updateProfilePicture(TargetProfileModel model) async {
    final profileRef = ref.read(myProfileServiceProviderImpl.notifier);

    await profileRef.updateProfilePicture(model, chosenPicture!);

    final profileState = ref.read(myProfileServiceProviderImpl);

    if (profileState.error == null) {
      Navigator.of(context).pop();

      await profileRef.getMyProfile();
    } else {
      showSnackBar(context, profileState.error!);
    }
  }

  @override
  void initState() {
    super.initState();
    getNames();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(myProfileServiceProviderImpl).data == null) {
        fetchMyProfile();
      }

      if (ref.read(subscriptionServiceProviderImpl).data == null) {
        ref
            .read(subscriptionServiceProviderImpl.notifier)
            .getSubscriptionPlans();
      }

      ref.read(videoPostServiceProviderImpl.notifier).getUserVideos();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final profileState = ref.watch(myProfileServiceProviderImpl);
    final subscriptionState = ref.watch(subscriptionServiceProviderImpl);
    final videoPostState = ref.watch(videoPostServiceProviderImpl);
    double width = MediaQuery.sizeOf(context).width;
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    print(videoPostState.data);
    print(videoPostState.isLoading);
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            isLightTheme ? GlobalColors.lightBackgroundColor : Colors.black,
        body: profileState.isLoading || profileState.data == null
            ? const LoadingScreen()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          height: width * 0.85,
                          width: width * 0.85,
                          child: InkWell(
                            onTap: () => showPictureDialog(
                                context: context,
                                image: {
                                  'image_url':
                                      profileState.data['profile_picture_url']
                                },
                                isEdit: true,
                                chosenPicture: chosenPicture,
                                updatePicture: updateChosenPicture,
                                savePicture: updateProfilePicture),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image(
                                image: CachedNetworkImageProvider(
                                    profileState.data['profile_picture_url']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          SizedBox(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10.0, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$firstname $lastname',
                                          style: TextStyle(
                                              fontSize: scaler.scale(24)),
                                        ),
                                        Text(
                                          '${profileState.data['user']['email']}',
                                          style: TextStyle(
                                              fontSize: scaler.scale(10),
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                      ]),
                                  IconButton(
                                      onPressed: () =>
                                          showEditMyProfileComponent(
                                              context: context,
                                              targetProfileModel:
                                                  TargetProfileModel.fromMap(
                                                      profileState.data)),
                                      icon: const Icon(
                                        Icons.edit_note,
                                        size: 50,
                                        color: GlobalColors.primaryColor,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          SizedBox(
                            width: width * 0.85,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Date of Birth',
                                          style: TextStyle(
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                        Text(DateFormat('MMMM d, y').format(
                                            DateTime.parse(
                                                profileState.data['dob'])))
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Gender',
                                          style: TextStyle(
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                        Text(profileState.data['gender']
                                            .toUpperCase())
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Marital Status',
                                          style: TextStyle(
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                        Text(
                                            '${profileState.data['marital_status']}')
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Home Address',
                                          style: TextStyle(
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                        Text(profileState.data['home_address']
                                            .toUpperCase())
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nickname',
                                          style: TextStyle(
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                        Text('${profileState.data['nickname']}')
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Username',
                                          style: TextStyle(
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                        Text(profileState.data['user']
                                            ['username'])
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Date Joined',
                                          style: TextStyle(
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                        Text(
                                            '${profileState.data['user']['date_joined'].split("T")[0]}')
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Last Login',
                                          style: TextStyle(
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                        Text(profileState.data['user']
                                                ['last_login']
                                            .split("T")[0])
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          height: 150,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: subscriptionState.isLoading ||
                                    subscriptionState.data == null
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: GlobalColors.primaryColor,
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: subscriptionState.data.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2.0),
                                        child: SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: InkWell(
                                              onTap: () {},
                                              child: Card(
                                                color: isLightTheme
                                                    ? Colors.grey[300]
                                                    : Colors.grey[800],
                                                child: SizedBox(
                                                  height: 100,
                                                  child: Stack(
                                                    children: [
                                                      // Main content
                                                      Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              subscriptionState
                                                                          .data[
                                                                      index]
                                                                  ['name'],
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Text(
                                                                '${subscriptionState.data[index]['rw_price']} RWF'),
                                                            const SizedBox(
                                                                height: 10),
                                                            Text(
                                                                '${subscriptionState.data[index]['usd_price']} USD'),
                                                          ],
                                                        ),
                                                      ),

                                                      if (subscriptionState
                                                                          .data[
                                                                      index]
                                                                  ['code'] ==
                                                              profileState.data[
                                                                      'subscription']
                                                                  [
                                                                  'plan_code'] &&
                                                          profileState.data[
                                                                      'subscription']
                                                                  ['status'] ==
                                                              'active')
                                                        const Positioned(
                                                          top: 8,
                                                          right: 8,
                                                          child: Icon(
                                                            Icons.check_circle,
                                                            color: Colors.green,
                                                            size: 20,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              )),
                                        ),
                                      );
                                    },
                                  ),
                          )),
                      SizedBox(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: DefaultTabController(
                                length: 2,
                                child: Column(
                                  children: [
                                    TabBar(
                                      tabs: const [
                                        Tab(text: 'Profile Pictures'),
                                        Tab(text: 'Video Posts'),
                                      ],
                                      labelColor: GlobalColors.primaryColor,
                                      unselectedLabelColor:
                                          GlobalColors.secondaryColor,
                                    ),
                                    SizedBox(
                                      height: 250,
                                      child: TabBarView(
                                        children: [
                                          // Pictures Tab
                                          GridView.builder(
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 4,
                                              mainAxisSpacing: 4,
                                            ),
                                            itemCount: profileState
                                                .data['profile_images'].length,
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () => showPictureDialog(
                                                  context: context,
                                                  image: profileState.data[
                                                      'profile_images'][index],
                                                  isEdit: true,
                                                  chosenPicture: chosenPicture,
                                                  updatePicture:
                                                      updateChosenPicture,
                                                  savePicture: replaceImage,
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: profileState.data[
                                                          'profile_images']
                                                      [index]['image_url'],
                                                  fit: BoxFit.cover,
                                                ),
                                              );
                                            },
                                          ),
                                          // Videos Tab
                                          videoPostState.isLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: GlobalColors
                                                        .primaryColor,
                                                  ),
                                                )
                                              : videoPostState.data.isEmpty
                                                  ? Center(
                                                      child: Text(
                                                        'No videos yet',
                                                        style: TextStyle(
                                                          color: GlobalColors
                                                              .secondaryColor,
                                                        ),
                                                      ),
                                                    )
                                                  : GridView.builder(
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        crossAxisSpacing: 4,
                                                        mainAxisSpacing: 4,
                                                      ),
                                                      itemCount: videoPostState
                                                          .data.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return InkWell(
                                                          onTap: () {},
                                                          child: Container(
                                                            color: Colors.black,
                                                            height: 50,
                                                            width: 50,
                                                            child: const Center(
                                                              child: Icon(Icons
                                                                  .play_arrow),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                            // InkWell(
                            //   onTap: () {
                            //     if (expandedField == 'media') {
                            //       setState(() {
                            //         expandedField = '';
                            //       });
                            //     } else {
                            //       setState(() {
                            //         expandedField = 'media';
                            //       });
                            //     }
                            //   },
                            //   child: ListTile(
                            //     title: const Text(
                            //       'My Media',
                            //       style: TextStyle(fontWeight: FontWeight.bold),
                            //     ),
                            //     subtitle:
                            //         const Text('View your pictures and videos'),
                            //     trailing: expandedField == 'media'
                            //         ? const Icon(Icons.keyboard_arrow_down)
                            //         : const Icon(Icons.keyboard_arrow_right),
                            //   ),
                            // ),
                            // if (expandedField == 'media')

                            // InkWell(
                            //   onTap: () {},
                            //   child: const ListTile(
                            //     title: Text(
                            //       'Subscription',
                            //       style: TextStyle(fontWeight: FontWeight.bold),
                            //     ),
                            //     subtitle: Text('Click to change your profile'),
                            //     trailing: Icon(Icons.keyboard_arrow_right),
                            //   ),
                            // )
                          ],
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Hide Profile'),
                        value: profileState.data['hide_profile'],
                        onChanged: (value) {},
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
