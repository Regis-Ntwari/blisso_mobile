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

  // Helper to format the goal text
  String formatGoal(String? goal) {
    if (goal == null || goal.isEmpty || goal.startsWith("["))
      return "Still Figuring It Out";
    return goal; // Assumes labels are already formatted in constants
  }

  Map<String, Map<String, List<dynamic>>> _groupByCategoryAndSubCategory(
      List<dynamic> snapshots) {
    final Map<String, Map<String, List<dynamic>>> grouped = {};
    for (final snap in snapshots) {
      final category = snap['category']?.toString() ?? 'Other';
      final subCategory = snap['sub_category']?.toString() ?? 'Other';
      grouped.putIfAbsent(category, () => {});
      grouped[category]!.putIfAbsent(subCategory, () => []);
      grouped[category]![subCategory]!.add(snap);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final targetProfile = ref.watch(targetProfileProvider);
    double width = MediaQuery.sizeOf(context).width;
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color cardColor =
        isLightTheme ? Colors.grey.shade50 : const Color(0xFF050505);
    final videoState = ref.watch(videoPostServiceProviderImpl);

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isLightTheme ? Colors.white : Colors.black,
        leading: IconButton(
          onPressed: () => Routemaster.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: GlobalColors.primaryColor),
        ),
        centerTitle: true,
        title: Text('${targetProfile.nickname}',
            style: TextStyle(
                fontSize: 22,
                color: GlobalColors.primaryColor,
                fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile Image Section
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: SizedBox(
                    height: width * 0.85,
                    width: width * 0.85,
                    child: InkWell(
                      onTap: () => Routemaster.of(context).push(
                          '/homepage/target-profile/image-viewer?url=${targetProfile.profilePictureUri!}&isMe=false&isProfilePic=false'),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CachedNetworkImage(
                          imageUrl: targetProfile.profilePictureUri ??
                              'https://plus.unsplash.com/premium_vector-1719858611039-66c134efa74d',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                  color: GlobalColors.primaryColor)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Name & Relationship Goal Hero Card
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      '${targetProfile.user!['first_name']} ${targetProfile.user!['last_name']}',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isLightTheme ? Colors.black : Colors.white),
                    ),
                    const SizedBox(height: 16),

                    if (targetProfile.feeling != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: GlobalColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Feeling ${targetProfile.feeling!}',
                          style: TextStyle(
                            fontSize: 12,
                            color: GlobalColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // FANCY LOOKING FOR CARD
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GlobalColors.primaryColor.withOpacity(0.12),
                            GlobalColors.primaryColor.withOpacity(0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: GlobalColors.primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: GlobalColors.primaryColor,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.auto_awesome_outlined,
                                color: Colors.white, size: 10),
                          ),
                          const SizedBox(width: 14),
                          Text("LOOKING FOR",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: GlobalColors.primaryColor,
                                  letterSpacing: 1.2)),
                          const SizedBox(width: 8),
                          Text(
                            formatGoal(targetProfile.lookingFor),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                                color: isLightTheme
                                    ? Colors.black87
                                    : Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Personal Info Detail Card
              Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoRow(
                          label: 'Date of Birth',
                          value: DateFormat('MMMM d, y')
                              .format(DateTime.parse(targetProfile.dob!))),
                      _buildInfoRow(
                          label: 'Gender',
                          value: targetProfile.gender.toString().toUpperCase()),
                      _buildInfoRow(
                          label: 'Marital Status',
                          value: targetProfile.maritalStatus
                              .toString()
                              .toUpperCase()),
                      _buildInfoRow(
                          label: 'Nationality',
                          value: targetProfile.nationality
                              .toString()
                              .toUpperCase()),
                      _buildInfoRow(
                          label: 'Residence',
                          value:
                              "${targetProfile.residenceCity}, ${targetProfile.residenceCountry}"
                                  .toUpperCase(),
                          isLast: true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 4. Expandable Snapshots
              _buildExpandableSection(
                title: "About ${targetProfile.nickname}",
                subtitle: targetProfile.lifesnapshots!
                    .map((s) => s['name'])
                    .join(", "),
                isExpanded: expandedField == 'interest',
                onTap: () => setState(() => expandedField =
                    expandedField == 'interest' ? '' : 'interest'),
                expandedContent:
                    _buildGroupedSnapshots(targetProfile.lifesnapshots!),
              ),
              const SizedBox(height: 12),
              _buildExpandableSection(
                title: "Looking for in a partner",
                subtitle: targetProfile.targetLifesnapshots!
                    .map((s) => s['name'])
                    .join(", "),
                isExpanded: expandedField == 'target',
                onTap: () => setState(() =>
                    expandedField = expandedField == 'target' ? '' : 'target'),
                expandedContent:
                    _buildGroupedSnapshots(targetProfile.targetLifesnapshots!),
              ),

              const SizedBox(height: 24),

              // 5. DM Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ButtonComponent(
                  text: isLoading ? 'Texting...' : 'Text Me',
                  backgroundColor: GlobalColors.primaryColor,
                  foregroundColor: Colors.white,
                  onTap: isLoading ? () {} : () => handleDMTap(context),
                ),
              ),

              const SizedBox(height: 24),

              // 6. Media Tabs (Photos/Videos)
              _buildMediaSection(
                  targetProfile, videoState, cardColor, isLightTheme),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoRow(
      {required String label, required String value, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.1)))),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: GlobalColors.secondaryColor,
                      fontWeight: FontWeight.w500))),
          Expanded(
              flex: 2,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
      {required String title,
      required String subtitle,
      required bool isExpanded,
      required VoidCallback onTap,
      required Widget expandedContent}) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return Card(
      color: isLightTheme ? Colors.grey.shade50 : const Color(0xFF050505),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            title: Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle:
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: GlobalColors.primaryColor),
          ),
          if (isExpanded)
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: expandedContent),
        ],
      ),
    );
  }

  Widget _buildGroupedSnapshots(List<dynamic> snapshots) {
    final grouped = _groupByCategoryAndSubCategory(snapshots);
    return Column(
      children: grouped.entries
          .map((cat) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.key,
                      style: TextStyle(
                          color: GlobalColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cat.value.values
                          .expand((e) => e)
                          .map((snap) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: GlobalColors.primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(snap['name'],
                                    style: TextStyle(
                                        color: GlobalColors.primaryColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ))
                          .toList()),
                  const SizedBox(height: 16),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildMediaSection(
      targetProfile, videoState, cardColor, isLightTheme) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              indicatorColor: GlobalColors.primaryColor,
              labelColor: GlobalColors.primaryColor,
              unselectedLabelColor: GlobalColors.secondaryColor,
              tabs: const [Tab(text: 'Photos'), Tab(text: 'Videos')],
            ),
            SizedBox(
              height: 350,
              child: TabBarView(
                children: [
                  _buildPhotoGrid(targetProfile),
                  _buildVideoGrid(videoState, isLightTheme),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(targetProfile) {
    if (targetProfile.profileImages!.isEmpty)
      return const Center(child: Text("No photos yet"));
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: targetProfile.profileImages!.length,
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: () => Routemaster.of(context).push(
              '/homepage/target-profile/image-viewer?url=${targetProfile.profileImages![index]['image_url']}&isMe=false&isProfilePic=false'),
          child: CachedNetworkImage(
              imageUrl: targetProfile.profileImages![index]['image_url'],
              fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildVideoGrid(videoState, isLightTheme) {
    if (videoState.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (videoState.data.isEmpty)
      return const Center(child: Text("No videos yet"));
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6),
      itemCount: videoState.data.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          Routemaster.of(context).push(
            '/homepage/target-profile/video-player?id=${Uri.encodeComponent(videoState.data[index]['id'].toString())}',
          );
        },
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                    image: NetworkImage(
                        videoState.data[index]['post_video_thumbnail_url']),
                    fit: BoxFit.cover)),
            child: Center(child: const Icon(Icons.play_circle_outline))),
      ),
    );
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
              Routemaster.of(context)
                  .push('/homepage/chat-detail/$targetUsername');
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
}
