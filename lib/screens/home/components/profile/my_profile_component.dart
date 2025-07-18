import 'dart:io';

import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/added_snaps_provider.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/show_snapshot_dialog_component.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/show_target_snapshot_dialog.dart';
import 'package:blisso_mobile/screens/utils/subscription/chosen_options_provider.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/my_profile_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service_provider.dart';
import 'package:blisso_mobile/services/video-post/video_post_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';

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
  String selectedOption = 'RWF';
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
    final profileRef = ref.read(myProfileServiceProviderImpl.notifier);
    final profileState = ref.watch(myProfileServiceProviderImpl);
    final subscriptionState = ref.watch(subscriptionServiceProviderImpl);
    final videoPostState = ref.watch(videoPostServiceProviderImpl);
    final snapshotState = ref.watch(snapshotServiceProviderImpl);
    double width = MediaQuery.sizeOf(context).width;
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
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
                            onTap: () => Routemaster.of(context).push(
                                '/homepage/image-viewer?url=${profileState.data['profile_picture_url']}&isProfilePic=true&isMe=true'),
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
                                      onPressed: () => Routemaster.of(context)
                                          .push('/homepage/edit-profile'),
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
                      profileState.data['feeling_caption'] != null
                          ? Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Text(
                                  'Feeling ${profileState.data['feeling_caption']}${profileState.data['feeling_emojis']}'),
                            )
                          : const SizedBox.shrink(),
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
                            child:
                                subscriptionState.isLoading ||
                                        subscriptionState.data == null
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: GlobalColors.primaryColor,
                                        ),
                                      )
                                    : Center(
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              subscriptionState.data.length,
                                          itemBuilder: (context, index) {
                                            return subscriptionState.data[index]
                                                        ['rw_price'] ==
                                                    0
                                                ? const SizedBox.shrink()
                                                : Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 2.0),
                                                    child: SizedBox(
                                                      height: 100,
                                                      width: 100,
                                                      child: InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                String?
                                                                    tempSelected =
                                                                    selectedOption; // local copy to update inside dialog

                                                                return StatefulBuilder(
                                                                  builder: (context,
                                                                      setState) {
                                                                    return Dialog(
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            16),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            const Text('Choose Currency'),
                                                                            const SizedBox(height: 10),
                                                                            RadioListTile<String>(
                                                                              title: const Text('RWF'),
                                                                              value: 'RWF',
                                                                              groupValue: tempSelected,
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  tempSelected = value!;
                                                                                });
                                                                              },
                                                                            ),
                                                                            RadioListTile<String>(
                                                                              title: const Text('USD'),
                                                                              value: 'USD',
                                                                              groupValue: tempSelected,
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  tempSelected = value!;
                                                                                });
                                                                              },
                                                                            ),
                                                                            const SizedBox(height: 20),
                                                                            ButtonComponent(
                                                                              text: 'Submit',
                                                                              backgroundColor: Colors.white,
                                                                              foregroundColor: Colors.black,
                                                                              onTap: () {
                                                                                Navigator.pop(context);
                                                                                // Update the actual selectedOption in parent
                                                                                setState(() {
                                                                                  selectedOption = tempSelected!;
                                                                                });
                                                                                final chosenOptionRef = ref.read(chosenOptionsProviderImpl.notifier);
                                                                                chosenOptionRef.addOption('currency', selectedOption);
                                                                                chosenOptionRef.addOption('amount', selectedOption == 'RWF' ? subscriptionState.data[index]['rw_price'] : subscriptionState.data[index]['usd_price']);

                                                                                chosenOptionRef.addOption('code', subscriptionState.data[index]['code']);
                                                                                Routemaster.of(context).push(
                                                                                  '/homepage/subscription'
                                                                                  '?code=${subscriptionState.data[index]['code']}'
                                                                                  '&name=${subscriptionState.data[index]['name']}'
                                                                                  '&rwPrice=${subscriptionState.data[index]['rw_price']}'
                                                                                  '&usdPrice=${subscriptionState.data[index]['usd_price']}'
                                                                                  '&months=${subscriptionState.data[index]['months']}'
                                                                                  '&currency=$selectedOption',
                                                                                );
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: Card(
                                                            color: isLightTheme
                                                                ? Colors
                                                                    .grey[300]
                                                                : Colors
                                                                    .grey[800],
                                                            child: SizedBox(
                                                              height: 100,
                                                              child: Stack(
                                                                children: [
                                                                  // Main content
                                                                  Center(
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          subscriptionState.data[index]
                                                                              [
                                                                              'name'],
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        Text(
                                                                            '${subscriptionState.data[index]['rw_price']} RWF'),
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        Text(
                                                                            '${subscriptionState.data[index]['usd_price']} USD'),
                                                                      ],
                                                                    ),
                                                                  ),

                                                                  if (subscriptionState.data[index]
                                                                              [
                                                                              'code'] ==
                                                                          profileState.data['subscription']
                                                                              [
                                                                              'plan_code'] &&
                                                                      profileState.data['subscription']
                                                                              [
                                                                              'status'] ==
                                                                          'active')
                                                                    const Positioned(
                                                                      top: 8,
                                                                      right: 8,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .check_circle,
                                                                        color: Colors
                                                                            .green,
                                                                        size:
                                                                            20,
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
                                                onTap: () => Routemaster.of(
                                                        context)
                                                    .push(
                                                        '/homepage/image-viewer?url=${profileState.data['profile_images'][index]['image_url']}&isMe=true&isProfilePic=false&id=${profileState.data['profile_images'][index]['id']}'),
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
                                                          onTap: () {
                                                            Routemaster.of(
                                                                    context)
                                                                .push(
                                                                    '/homepage/video-player?id=${Uri.encodeComponent(videoPostState.data[index]['id'].toString())}');
                                                          },
                                                          child: Container(
                                                            color: isLightTheme
                                                                ? Colors.black
                                                                : Colors
                                                                    .grey[800],
                                                            height: 50,
                                                            width: 50,
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons
                                                                    .play_arrow,
                                                                color: Colors
                                                                    .white,
                                                              ),
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
                                child: snapshotState.isLoading
                                    ? const CircularProgressIndicator(
                                        color: GlobalColors.primaryColor,
                                      )
                                    : Wrap(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              final snaps = ref.read(
                                                  addedSnapsProviderImpl
                                                      .notifier);
                                              snaps.reset();
                                              for (var snap in profileState
                                                  .data['lifesnapshots']) {
                                                snaps.addSnapshot(
                                                    snap['lifesnapshot_id']);
                                              }
                                              showSnapshotDialog(context, ref);
                                            },
                                            child: const Padding(
                                              padding:  EdgeInsets.symmetric(vertical: 20.0),
                                              child:  Row(
                                                children: [
                                                  Icon(Icons.add),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text('Add Snapshots')
                                                ],
                                              ),
                                            ),
                                          ),
                                          ...profileState.data['lifesnapshots']
                                              .map<Widget>((snapshot) {
                                            return ListTile(
                                              title: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: const Color.fromARGB(255, 139, 42, 42)),
                                                  child: Text(
                                                    snapshot['name'],
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  )),
                                              trailing: IconButton(
                                                onPressed: () async {
                                                  await ref
                                                      .read(
                                                          snapshotServiceProviderImpl
                                                              .notifier)
                                                      .deleteProfileSnapshot(
                                                          snapshot['id']);
                                                  ref
                                                      .read(
                                                          myProfileServiceProviderImpl
                                                              .notifier)
                                                      .removeSnapshotById(
                                                          snapshot['id']);
                                                },
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color:
                                                      GlobalColors.primaryColor,
                                                ),
                                              ),
                                            );
                                          }).toList()
                                        ],
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
                                child: Wrap(children: [
                                  InkWell(
                                    onTap: () {
                                      showTargetSnapshotDialog(context, ref);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.add),
                                          SizedBox(width: 10),
                                          Text('Add Target Snapshot')
                                        ],
                                      ),
                                    ),
                                  ),
                                  ...profileState.data['target_lifesnapshots']
                                      .map<Widget>((snapshot) {
                                    return ListTile(
                                      title: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: GlobalColors.primaryColor),
                                          child: Text(
                                            '${snapshot['name']} - ${snapshot['target_scale']}/10',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )),
                                      trailing: IconButton(
                                        onPressed: () async {
                                          await ref
                                              .read(snapshotServiceProviderImpl
                                                  .notifier)
                                              .deleteTargetSnapshot(
                                                  snapshot['id']);
                                          ref
                                              .read(myProfileServiceProviderImpl
                                                  .notifier)
                                              .removeTargetSnapshot(
                                                  snapshot['id']);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: GlobalColors.primaryColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ]),
                              ),
                          ],
                        ),
                      ),
                      SwitchListTile(
                        activeColor: GlobalColors.primaryColor,
                        title: const Text('Hide Profile'),
                        value: profileState.data['hide_profile'],
                        onChanged: (value) async {
                          setState(() {
                            profileState.data['hide_profile'] = value;
                          });

                          await ref
                              .read(myProfileServiceProviderImpl.notifier)
                              .updateProfile(
                                  TargetProfileModel.fromMapNewNoProfile({
                                ...profileState.data,
                                'hide_profile': value
                              }));
                        },
                      ),
                      SwitchListTile(
                        activeColor: GlobalColors.primaryColor,
                        title: const Text('Push Notifications'),
                        value: profileState.data['push_notifications'],
                        onChanged: (value) async {
                          setState(() {
                            profileState.data['push_notifications'] = value;
                          });
                          await ref
                              .read(myProfileServiceProviderImpl.notifier)
                              .updateProfile(
                                  TargetProfileModel.fromMapNewNoProfile({
                                ...profileState.data,
                                'push_notifications': value
                              }));
                        },
                      ),
                      SwitchListTile(
                        activeColor: GlobalColors.primaryColor,
                        title: const Text('Login Code Enabled'),
                        value: profileState.data['login_code_enabled'],
                        onChanged: (value) async {
                          setState(() {
                            profileState.data['login_code_enabled'] = value;
                          });
                          await SharedPreferencesService.setPreference('login_code_enabled', value);
                          await ref
                              .read(myProfileServiceProviderImpl.notifier)
                              .updateProfile(
                                  TargetProfileModel.fromMapNewNoProfile({
                                ...profileState.data,
                                'login_code_enabled': value
                              }));
                        },
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
