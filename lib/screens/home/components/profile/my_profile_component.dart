import 'dart:io';

import 'package:blisso_mobile/components/loading_component.dart';
//import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/added_snaps_provider.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/added_target_snaps_provider.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/show_snapshot_dialog_component.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/show_target_snapshot_dialog.dart';
import 'package:blisso_mobile/screens/home/components/profile/video_post_options_component.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/my_profile_service_provider.dart';
import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service_provider.dart';
import 'package:blisso_mobile/services/video-post/user_video_post_service_provider.dart';
import 'package:blisso_mobile/services/video-post/video_post_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
//import 'package:blisso_mobile/utils/subscription_design.dart';
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

      ref.read(userVideoPostServiceProviderImpl.notifier).getUserVideos();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final profileState = ref.watch(myProfileServiceProviderImpl);
    final videoPostState = ref.watch(userVideoPostServiceProviderImpl);
    final snapshotState = ref.watch(snapshotServiceProviderImpl);
    double width = MediaQuery.sizeOf(context).width;
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color cardColor =
        isLightTheme ? Colors.grey.shade50 : Color(0xFF050505);
    final Color dividerColor =
        isLightTheme ? Colors.grey.shade300 : Colors.grey.shade700;

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isLightTheme ? Colors.white : Colors.black,
        title: Text(
          'My Profile',
          style: TextStyle(
            fontSize: 24,
            color: GlobalColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Routemaster.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: GlobalColors.primaryColor,
          ),
        ),
        elevation: 0,
      ),
      body: profileState.isLoading || profileState.data == null
          ? const LoadingScreen()
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          // Profile Picture
                          Stack(
                            children: [
                              Container(
                                width: width * 0.4,
                                height: width * 0.4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: GlobalColors.primaryColor,
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: InkWell(
                                    onTap: () => Routemaster.of(context).push(
                                      '/homepage/profile/image-viewer?url=${profileState.data['profile_picture_url']}&id=-1&isProfilePic=true&isMe=true',
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: profileState
                                          .data['profile_picture_url'],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          color: GlobalColors.primaryColor,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                        Icons.person,
                                        size: width * 0.2,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: GlobalColors.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isLightTheme
                                          ? Colors.white
                                          : Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () => Routemaster.of(context)
                                        .push('/homepage/profile/edit-profile'),
                                    icon: Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Name and Email
                          Text(
                            '$firstname $lastname',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isLightTheme ? Colors.black : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profileState.data['user']['email'],
                            style: TextStyle(
                              fontSize: 14,
                              color: GlobalColors.secondaryColor,
                            ),
                          ),
                          // Feeling Status
                          if (profileState.data['feeling_caption'] != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    GlobalColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Feeling ${profileState.data['feeling_caption']}${profileState.data['feeling_emojis']}',
                                style: TextStyle(
                                  color: GlobalColors.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Personal Info Card
                    Card(
                      color: cardColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Row 1
                            _buildInfoRow(
                              label: 'Date of Birth',
                              value: DateFormat('MMMM d, y').format(
                                DateTime.parse(profileState.data['dob']),
                              ),
                              isFirst: true,
                            ),
                            _buildInfoRow(
                              label: 'Gender',
                              value: profileState.data['gender']
                                  .toString()
                                  .toUpperCase(),
                              isLast: true,
                            ),
                            const SizedBox(height: 16),
                            // Row 2
                            _buildInfoRow(
                              label: 'Marital Status',
                              value: profileState.data['marital_status']
                                  .toString()
                                  .toUpperCase(),
                              isFirst: true,
                            ),
                            _buildInfoRow(
                              label: 'Home Address',
                              value: profileState.data['home_address']
                                  .toUpperCase(),
                              isLast: true,
                            ),
                            const SizedBox(height: 16),
                            // Row 3
                            _buildInfoRow(
                              label: 'Nickname',
                              value: profileState.data['nickname'],
                              isFirst: true,
                            ),
                            _buildInfoRow(
                              label: 'Username',
                              value: profileState.data['user']['username'],
                              isLast: true,
                            ),
                            const SizedBox(height: 16),
                            // Row 4
                            _buildInfoRow(
                              label: 'Date Joined',
                              value: profileState.data['user']['date_joined']
                                  .split("T")[0],
                              isFirst: true,
                            ),
                            _buildInfoRow(
                              label: 'Last Login',
                              value: profileState.data['user']['last_login']
                                  .split("T")[0],
                              isLast: true,
                            ),
                            const SizedBox(height: 16),
                            // Row 5
                            _buildInfoRow(
                              label: 'Show Me',
                              value: profileState.data['show_me']
                                  .toString()
                                  .toUpperCase(),
                              isFirst: true,
                            ),
                            _buildInfoRow(
                              label: 'Distance Measure',
                              value: profileState.data['distance_measure'],
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Media Tabs
                    Card(
                      color: cardColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  color: isLightTheme
                                      ? Colors.grey.shade100
                                      : Color(0xFF050505),
                                ),
                                child: TabBar(
                                  indicator: const UnderlineTabIndicator(
                                    borderSide: BorderSide(
                                      color: GlobalColors.primaryColor,
                                      width: 3,
                                    ),
                                    insets:
                                        EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  labelColor: GlobalColors.primaryColor,
                                  unselectedLabelColor:
                                      GlobalColors.secondaryColor,
                                  tabs: const [
                                    Tab(
                                      icon: Icon(Icons.photo_library),
                                      text: 'Photos',
                                    ),
                                    Tab(
                                      icon: Icon(Icons.video_library),
                                      text: 'Videos',
                                    ),
                                  ],
                                )),
                            SizedBox(
                              height: 400,
                              child: TabBarView(
                                children: [
                                  // Photos Tab
                                  profileState.data['profile_images'].isEmpty
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.photo_library_outlined,
                                                size: 64,
                                                color:
                                                    GlobalColors.secondaryColor,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'No photos yet',
                                                style: TextStyle(
                                                  color: GlobalColors
                                                      .secondaryColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : GridView.builder(
                                          padding: const EdgeInsets.all(16),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                            mainAxisExtent: 160,
                                          ),
                                          itemCount: profileState
                                              .data['profile_images'].length,
                                          itemBuilder: (context, index) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: InkWell(
                                                onTap: () =>
                                                    Routemaster.of(context)
                                                        .push(
                                                  '/homepage/profile/image-viewer?url=${profileState.data['profile_images'][index]['image_url']}&isMe=true&isProfilePic=false&id=${profileState.data['profile_images'][index]['id']}',
                                                ),
                                                child: Stack(
                                                  children: [
                                                    CachedNetworkImage(
                                                      imageUrl: profileState
                                                                  .data[
                                                              'profile_images']
                                                          [index]['image_url'],
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .bottomCenter,
                                                          end: Alignment
                                                              .topCenter,
                                                          colors: [
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.5),
                                                            Colors.transparent,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  // Videos Tab
                                  videoPostState.isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: GlobalColors.primaryColor,
                                          ),
                                        )
                                      : videoPostState.data.isEmpty
                                          ? Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.videocam_off_outlined,
                                                    size: 64,
                                                    color: GlobalColors
                                                        .secondaryColor,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'No videos yet',
                                                    style: TextStyle(
                                                      color: GlobalColors
                                                          .secondaryColor,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : GridView.builder(
                                              padding: const EdgeInsets.all(16),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                crossAxisSpacing: 8,
                                                mainAxisSpacing: 8,
                                                mainAxisExtent: 120,
                                              ),
                                              itemCount:
                                                  videoPostState.data.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onLongPress: () async {
                                                    showVideoPostOptions(
                                                      context,
                                                      videoPostState.data[index]
                                                          ['id'],
                                                    );
                                                    await ref
                                                        .read(
                                                            profileServiceProviderImpl
                                                                .notifier)
                                                        .getMyProfile();
                                                  },
                                                  onTap: () {
                                                    Routemaster.of(context)
                                                        .push(
                                                      '/homepage/profile/video-player?id=${Uri.encodeComponent(videoPostState.data[index]['id'].toString())}',
                                                    );
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          color: isLightTheme
                                                              ? Colors
                                                                  .grey.shade800
                                                              : Colors.grey
                                                                  .shade900,
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons
                                                                  .play_arrow_rounded,
                                                              size: 32,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              begin: Alignment
                                                                  .bottomCenter,
                                                              end: Alignment
                                                                  .topCenter,
                                                              colors: [
                                                                Colors.black
                                                                    .withOpacity(
                                                                        0.6),
                                                                Colors
                                                                    .transparent,
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 8,
                                                          left: 8,
                                                          right: 8,
                                                          child: Text(
                                                            'Video ${index + 1}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
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

                    const SizedBox(height: 24),

                    // Interests Sections
                    _buildExpandableSection(
                      title: 'My Interests',
                      subtitle: profileState.data['lifesnapshots']
                          .map((snapshot) => snapshot['name'])
                          .join(", "),
                      isExpanded: expandedField == 'interest',
                      onTap: () {
                        setState(() {
                          expandedField =
                              expandedField == 'interest' ? '' : 'interest';
                        });
                      },
                      expandedContent: snapshotState.isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: GlobalColors.primaryColor,
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // Add Snapshot Button
                                _buildAddButton(
                                  icon: Icons.add,
                                  label: 'Add Snapshots',
                                  onTap: () {
                                    final snaps = ref.read(
                                      addedSnapsProviderImpl.notifier,
                                    );
                                    snaps.reset();
                                    for (var snap
                                        in profileState.data['lifesnapshots']) {
                                      snaps.addSnapshot(
                                        snap,
                                      );
                                    }

                                    print(ref.read(addedSnapsProviderImpl));
                                    showSnapshotDialog(context, ref);
                                  },
                                ),
                                // Snapshot Items
                                ...profileState.data['lifesnapshots']
                                    .map<Widget>((snapshot) {
                                  return Chip(
                                    backgroundColor: GlobalColors.primaryColor,
                                    label: Text(
                                      snapshot['name'],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    deleteIcon: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    onDeleted: () async {
                                      await ref
                                          .read(snapshotServiceProviderImpl
                                              .notifier)
                                          .deleteProfileSnapshot(
                                              snapshot['lifesnapshot_id']);
                                      ref
                                          .read(myProfileServiceProviderImpl
                                              .notifier)
                                          .removeSnapshotById(
                                              snapshot['lifesnapshot_id']);
                                    },
                                  );
                                }).toList(),
                              ],
                              ),
                    ),

                    const SizedBox(height: 16),

                    _buildExpandableSection(
                      title: 'My interests in a person',
                      subtitle: profileState.data['target_lifesnapshots']
                          .map((snapshot) => snapshot['name'])
                          .join(", "),
                      isExpanded: expandedField == 'target',
                      onTap: () {
                        setState(() {
                          expandedField =
                              expandedField == 'target' ? '' : 'target';
                        });
                      },
                      expandedContent: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Add Target Button
                          _buildAddButton(
                            icon: Icons.add,
                            label: 'Add Target Snapshot',
                            onTap: () {
                              ref
                                  .read(addedTargetSnapsProviderImpl.notifier)
                                  .reset();
                              final snapTarget = ref
                                  .read(addedTargetSnapsProviderImpl.notifier);
                              for (var snap in profileState
                                  .data['target_lifesnapshots']) {
                                print(snap);
                                snapTarget.addSnapshot(
                                  snap,
                                );
                              }
                              showTargetSnapshotDialog(context, ref);
                            },
                          ),
                          // Target Snapshot Items
                          ...profileState.data['target_lifesnapshots']
                              .map<Widget>((snapshot) {
                            return Chip(
                              backgroundColor: GlobalColors.primaryColor,
                              label: Text(
                                '${snapshot['name']} - ${snapshot['target_scale']}/10',
                                style: const TextStyle(color: Colors.white),
                              ),
                              deleteIcon: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              onDeleted: () async {
                                await ref
                                    .read(snapshotServiceProviderImpl.notifier)
                                    .deleteTargetSnapshot(
                                        snapshot['lifesnapshot_id']);
                                ref
                                    .read(myProfileServiceProviderImpl.notifier)
                                    .removeTargetSnapshot(
                                        snapshot['lifesnapshot_id']);
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Settings
                    Card(
                      color: cardColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            activeColor: GlobalColors.primaryColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            title: Text(
                              'Profile Visibility',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color:
                                    isLightTheme ? Colors.black : Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              profileState.data['hide_profile']
                                  ? 'Your profile is hidden from others'
                                  : 'Your profile is visible to others',
                              style: TextStyle(
                                fontSize: 12,
                                color: GlobalColors.secondaryColor,
                              ),
                            ),
                            value: !profileState.data['hide_profile'],
                            onChanged: (value) async {
                              setState(() {
                                profileState.data['hide_profile'] = !value;
                              });

                              await ref
                                  .read(myProfileServiceProviderImpl.notifier)
                                  .updateProfile(
                                    TargetProfileModel.fromMapNewNoProfile({
                                      ...profileState.data,
                                      'hide_profile': !value,
                                    }),
                                  );
                            },
                          ),
                          Divider(
                            height: 1,
                            color: dividerColor,
                            indent: 20,
                          ),
                          SwitchListTile(
                            activeColor: GlobalColors.primaryColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            title: Text(
                              'Login Code',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color:
                                    isLightTheme ? Colors.black : Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              profileState.data['login_code_enabled']
                                  ? 'Login Code is enabled'
                                  : 'Click to enable login code',
                              style: TextStyle(
                                fontSize: 12,
                                color: GlobalColors.secondaryColor,
                              ),
                            ),
                            value: profileState.data['login_code_enabled'],
                            onChanged: (value) async {
                              setState(() {
                                profileState.data['login_code_enabled'] = value;
                              });
                              await SharedPreferencesService.setPreference(
                                'login_code_enabled',
                                value,
                              );
                              await ref
                                  .read(myProfileServiceProviderImpl.notifier)
                                  .updateProfile(
                                    TargetProfileModel.fromMapNewNoProfile({
                                      ...profileState.data,
                                      'login_code_enabled': value,
                                    }),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: GlobalColors.secondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget expandedContent,
  }) {
    return Card(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.grey.shade50
          : Color(0xFF050505),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: GlobalColors.secondaryColor,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: GlobalColors.primaryColor,
              size: 28,
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: expandedContent,
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: GlobalColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GlobalColors.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: GlobalColors.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: GlobalColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
