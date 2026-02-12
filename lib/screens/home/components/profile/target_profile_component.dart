import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/chat/get_chat_details_provider.dart';
import 'package:blisso_mobile/services/message_requests/add_message_request_service_provider.dart';
import 'package:blisso_mobile/services/permissions/permission_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/services/video-post/video_post_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';

class TargetProfileComponent extends ConsumerStatefulWidget {
  const TargetProfileComponent({super.key});

  @override
  ConsumerState<TargetProfileComponent> createState() =>
      _TargetProfileComponentState();
}

class _TargetProfileComponentState
    extends ConsumerState<TargetProfileComponent> {
  String expandedField = '';
  bool isLoading = false;

  Future<bool> checkIfChatExists(String username) async {
    final chatRef = ref.read(chatServiceProviderImpl);
    if (chatRef.data == null) {
      final chatRef = ref.read(chatServiceProviderImpl.notifier);
      await chatRef.getMessages();
    }

    for (var chat in chatRef.data) {
      if (chat.containsKey(username)) {
        return true;
      }
    }
    return false;
  }

  Map<String, List<dynamic>> _groupBySubCategory(List<dynamic> snapshots) {
    final Map<String, List<dynamic>> grouped = {};

    for (final snap in snapshots) {
      final subCategory = snap['sub_category']?.toString() ?? 'Other';
      if (!grouped.containsKey(subCategory)) {
        grouped[subCategory] = [];
      }
      grouped[subCategory]!.add(snap);
    }

    return grouped;
  }

  Future<void> handleDMTap(BuildContext context) async {
    if (ref.read(permissionProviderImpl)['can_send_message_request']) {
      final targetProfile = ref.watch(targetProfileProvider);
      final targetUsername = targetProfile.user!['username'];
      setState(() {
        isLoading = true;
      });

      try {
        final messageRequestRef =
            ref.read(addMessageRequestServiceProviderImpl.notifier);
        await messageRequestRef.sendMessageRequest(targetUsername);

        final messageRequestResponse =
            ref.read(addMessageRequestServiceProviderImpl);

        if (messageRequestResponse.error == null) {
          if (context.mounted) {
            // Show success popup
            if (messageRequestResponse.statusCode == 200) {
              final chatRef = ref.read(chatServiceProviderImpl);
              if (chatRef.data == null || chatRef.data.isEmpty) {
                final chatRef = ref.read(chatServiceProviderImpl.notifier);
                await chatRef.getMessages();
              }
              final chatsRef = ref.read(chatServiceProviderImpl);
              for (var chat in chatsRef.data) {
                if (chat['username'] == targetUsername) {
                  final chatDetailsRef =
                      ref.read(getChatDetailsProviderImpl.notifier);
                  chatDetailsRef.updateChatDetails({
                    'username': targetUsername,
                    'profile_picture': targetProfile.profilePictureUri,
                    'full_name':
                        '${targetProfile.user!['first_name']} ${targetProfile.user!['last_name']}',
                    'nickname': targetProfile.nickname,
                    'messages': chat['messages']
                  });
                }
              }
              setState(() {
                isLoading = false;
              });
              Routemaster.of(context).push('/homepage/chat-detail/$targetUsername');
            } else if (messageRequestResponse.statusCode == 201) {
              setState(() {
                isLoading = false;
              });
              showPopupComponent(
                  context: context,
                  icon: Icons.verified,
                  iconColor: Colors.green[800],
                  message:
                      'Message request sent to ${targetProfile.nickname}!');
            } else {
              setState(() {
                isLoading = false;
              });
              showPopupComponent(
                context: context,
                icon: Icons.error,
                iconColor: GlobalColors.primaryColor,
                message: messageRequestResponse.error!,
              );
            }
          }
        } else {
          setState(() {
            isLoading = false;
          });
          showPopupComponent(
              context: context,
              icon: Icons.error,
              iconColor: GlobalColors.primaryColor,
              message: messageRequestResponse.error!);
        }
      } catch (e) {
        if (context.mounted) {
          setState(() {
            isLoading = false;
          });
          // Show error popup
          showPopupComponent(
            context: context,
            icon: Icons.error,
            iconColor: GlobalColors.primaryColor,
            message: 'Failed to send message request: ${e.toString()}',
          );
        }
      }
    } else {
      showPopupComponent(
          context: context,
          icon: Icons.error,
          message: 'Please upgrade your plan to send message requests');
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetProfile = ref.watch(targetProfileProvider);
      ref
          .read(videoPostServiceProviderImpl.notifier)
          .getTargetVideos(targetProfile.user!['username']);
    });
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

  @override
  Widget build(BuildContext context) {
    final targetProfile = ref.watch(targetProfileProvider);
    double width = MediaQuery.sizeOf(context).width;
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color cardColor =
        isLightTheme ? Colors.grey.shade50 : Color(0xFF050505);
    final videoState = ref.watch(videoPostServiceProviderImpl);

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isLightTheme ? Colors.white : Colors.black,
        leading: IconButton(
          onPressed: () => Routemaster.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: GlobalColors.primaryColor,
          ),
        ),
        centerTitle: true,
        title: Text(
          '${targetProfile.nickname}',
          style: TextStyle(
            fontSize: 24,
            color: GlobalColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: width * 0.85,
                          width: width * 0.85,
                          child: InkWell(
                            onTap: () => Routemaster.of(context).push(
                                '/homepage/target-profile/image-viewer?url=${targetProfile.profilePictureUri!}&isMe=false&isProfilePic=false'),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                  imageUrl: targetProfile.profilePictureUri ==
                                          null
                                      ? 'https://plus.unsplash.com/premium_vector-1719858611039-66c134efa74d'
                                      : targetProfile.profilePictureUri!,
                                  placeholder: (context, url) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: GlobalColors.primaryColor,
                                      ),
                                    );
                                  },
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Name and Feeling
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      '${targetProfile.user!['first_name']} ${targetProfile.user!['last_name']}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isLightTheme ? Colors.black : Colors.white,
                      ),
                    ),
                    if (targetProfile.feeling != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: GlobalColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Feeling ${targetProfile.feeling}',
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
                      _buildInfoRow(
                        label: 'Date of Birth',
                        value: DateFormat('MMMM d, y').format(
                          DateTime.parse(targetProfile.dob!),
                        ),
                        isFirst: true,
                      ),
                      _buildInfoRow(
                        label: 'Gender',
                        value: targetProfile.gender.toString().toUpperCase(),
                        isFirst: true,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        label: 'Marital Status',
                        value: targetProfile.maritalStatus
                            .toString()
                            .toUpperCase(),
                        isFirst: true,
                      ),
                      _buildInfoRow(
                        label: 'Home Address',
                        value:
                            targetProfile.homeAddress.toString().toUpperCase(),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Interests Sections
              _buildExpandableSection(
                title: "${targetProfile.nickname}'s interests",
                subtitle: targetProfile.lifesnapshots!
                    .map((snapshot) => snapshot['name'])
                    .join(", "),
                isExpanded: expandedField == 'interest',
                onTap: () {
                  setState(() {
                    expandedField =
                        expandedField == 'interest' ? '' : 'interest';
                  });
                },
                expandedContent: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group snapshots by sub_category
                      ..._groupBySubCategory(targetProfile.lifesnapshots!)
                          .entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Sub-category title
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.category_rounded,
                                            size: 18,
                                            color: GlobalColors.primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            entry.key,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isLightTheme
                                                  ? Colors.black87
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Wrap badges
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        ...entry.value.map((snap) => Chip(
                                              backgroundColor:
                                                  GlobalColors.primaryColor,
                                              label: Text(
                                                snap['name'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildExpandableSection(
                title: "${targetProfile.nickname}'s interests in a person",
                subtitle: targetProfile.targetLifesnapshots!
                    .map((snapshot) => snapshot['name'])
                    .join(", "),
                isExpanded: expandedField == 'target',
                onTap: () {
                  setState(() {
                    expandedField = expandedField == 'target' ? '' : 'target';
                  });
                },
                expandedContent: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group snapshots by sub_category
                      ..._groupBySubCategory(targetProfile.targetLifesnapshots!)
                          .entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Sub-category title
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.category_rounded,
                                            size: 18,
                                            color: GlobalColors.primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            entry.key,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isLightTheme
                                                  ? Colors.black87
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Wrap badges
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        ...entry.value.map((snap) => Chip(
                                              backgroundColor:
                                                  GlobalColors.primaryColor,
                                              label: Text(
                                                snap['name'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // DM Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ButtonComponent(
                  text: isLoading ? 'Sending...' : 'DM Me',
                  backgroundColor: GlobalColors.primaryColor,
                  foregroundColor: Colors.white,
                  onTap: isLoading ? () {} : () => handleDMTap(context),
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
                            insets: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          labelColor: GlobalColors.primaryColor,
                          unselectedLabelColor: GlobalColors.secondaryColor,
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
                        ),
                      ),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          children: [
                            // Photos Tab
                            targetProfile.profileImages!.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.photo_library_outlined,
                                          size: 64,
                                          color: GlobalColors.secondaryColor,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No photos yet',
                                          style: TextStyle(
                                            color: GlobalColors.secondaryColor,
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
                                    itemCount:
                                        targetProfile.profileImages!.length,
                                    itemBuilder: (context, index) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: InkWell(
                                          onTap: () => Routemaster.of(context).push(
                                              '/homepage/target-profile/image-viewer?url=${targetProfile.profileImages![index]['image_url']}&isMe=false&isProfilePic=false'),
                                          child: Stack(
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: targetProfile
                                                        .profileImages![index]
                                                    ['image_url'],
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                    colors: [
                                                      Colors.black
                                                          .withOpacity(0.5),
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
                            videoState.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: GlobalColors.primaryColor,
                                    ),
                                  )
                                : videoState.data.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.videocam_off_outlined,
                                              size: 64,
                                              color:
                                                  GlobalColors.secondaryColor,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No videos yet',
                                              style: TextStyle(
                                                color:
                                                    GlobalColors.secondaryColor,
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
                                        itemCount: videoState.data.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              Routemaster.of(context).push(
                                                  '/homepage/target-profile/video-player?id=${Uri.encodeComponent(videoState.data[index]['id'].toString())}');
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    color: isLightTheme
                                                        ? Colors.grey.shade800
                                                        : Colors.grey.shade900,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons
                                                            .play_arrow_rounded,
                                                        size: 32,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment
                                                            .bottomCenter,
                                                        end:
                                                            Alignment.topCenter,
                                                        colors: [
                                                          Colors.black
                                                              .withOpacity(0.6),
                                                          Colors.transparent,
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
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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

              const SizedBox(height: 32),
            ],
          ),
        ),
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
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    return Card(
      color: isLightTheme ? Colors.grey.shade50 : Color(0xFF050505),
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
                color: isLightTheme ? Colors.black : Colors.white,
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
}
