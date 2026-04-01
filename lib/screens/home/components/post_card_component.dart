import 'dart:math';

import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/expandable_text_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/screens/chat/attachments/message_request_modal.dart';
import 'package:blisso_mobile/services/chat/get_chat_details_provider.dart';
import 'package:blisso_mobile/services/message_requests/add_message_request_service_provider.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/permissions/permission_provider.dart';
import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';

class PostCardComponent extends ConsumerStatefulWidget {
  final Map<String, dynamic> profile;
  const PostCardComponent({super.key, required this.profile});

  @override
  ConsumerState<PostCardComponent> createState() => _PostCardComponentState();
}

class _PostCardComponentState extends ConsumerState<PostCardComponent> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Helper to format the relationship goal text
  String _getLookingForText(dynamic profile) {
    final goal = profile['relationship_goal'];
    if (goal == null || goal.toString().isEmpty) return "Still Figuring It Out";
    
    // Capitalize first letter of each word
    return goal.toString().split(' ').map((str) => 
      str.isNotEmpty ? str[0].toUpperCase() + str.substring(1).toLowerCase() : ""
    ).join(' ');
  }

  Future<void> handleDMTap(BuildContext context) async {
    if (ref.read(permissionProviderImpl)['can_send_message_request']) {
      setState(() => isLoading = true);
      final targetUsername = widget.profile['user']['username'];

      try {
        final messageRequestRef = ref.read(addMessageRequestServiceProviderImpl.notifier);
        await messageRequestRef.sendMessageRequest(targetUsername);
        final messageRequestResponse = ref.read(addMessageRequestServiceProviderImpl);

        if (messageRequestResponse.error == null) {
          if (context.mounted) {
            if (messageRequestResponse.statusCode == 200) {
              final chatRef = ref.read(chatServiceProviderImpl);
              if (chatRef.data == null || chatRef.data.isEmpty) {
                await ref.read(chatServiceProviderImpl.notifier).getMessages();
              }
              final chatsRef = ref.read(chatServiceProviderImpl);
              for (var chat in chatsRef.data) {
                if (chat['username'] == targetUsername) {
                  ref.read(getChatDetailsProviderImpl.notifier).updateChatDetails({
                    'username': targetUsername,
                    'profile_picture': widget.profile['profile_picture_url'],
                    'full_name': '${widget.profile['user']['first_name']} ${widget.profile['user']['last_name']}',
                    'nickname': widget.profile['nickname'],
                    'messages': chat['messages']
                  });
                }
              }
              Routemaster.of(context).push('/homepage/chat-detail/$targetUsername');
            } else if (messageRequestResponse.statusCode == 201) {
              showPopupComponent(
                  context: context,
                  icon: Icons.verified,
                  iconColor: Colors.green[800],
                  message: 'Message request sent to ${widget.profile['nickname']}!');
            }
          }
        } else {
          showPopupComponent(context: context, icon: Icons.error, message: messageRequestResponse.error!);
        }
      } catch (e) {
        showPopupComponent(context: context, icon: Icons.error, message: 'Failed to send request');
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    } else {
      showPopupComponent(context: context, icon: Icons.error, message: 'Please upgrade your plan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetProfile = ref.read(targetProfileProvider.notifier);
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    return Card(
      color: isLightTheme ? GlobalColors.whiteColor : Colors.black,
      margin: const EdgeInsets.only(bottom: 15),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: User Info & Feeling
          InkWell(
            onTap: () {
              if (ref.read(permissionProviderImpl)['can_view_profile_detail']) {
                targetProfile.updateTargetProfile(TargetProfileModel.fromMap(widget.profile));
                Routemaster.of(context).push('/homepage/target-profile');
              } else {
                showPopupComponent(context: context, icon: Icons.error, message: 'Please upgrade your plan');
              }
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(widget.profile['profile_picture_url'] ??
                    'https://plus.unsplash.com/premium_vector-1719858611039-66c134efa74d'),
              ),
              title: Row(
                children: [
                  Text(widget.profile['nickname'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(' • ${widget.profile['age']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: GlobalColors.primaryColor),
                  const SizedBox(width: 2),
                  Text('${widget.profile['distance_annot']}', style: const TextStyle(fontSize: 12)),
                ],
              ),
              trailing: widget.profile['feeling_caption'] != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.profile['feeling_emojis'], style: const TextStyle(fontSize: 20)),
                        Text(widget.profile['feeling_caption'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    )
                  : null,
            ),
          ),

          // MEDIA: Image PageView
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxWidth,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() => _currentPage = value),
                  itemCount: widget.profile['profile_images'].length,
                  itemBuilder: (context, index) => CachedNetworkImage(
                    imageUrl: widget.profile['profile_images'][index]['image_url'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: GlobalColors.primaryColor)),
                  ),
                ),
              );
            },
          ),

          // INDICATOR & FANCY LOOKING FOR BANNER
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                // Minimalist Page Indicator
                Row(
                  children: List.generate(
                    widget.profile['profile_images'].length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: _currentPage == index ? 10 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? GlobalColors.primaryColor : Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // FANCY "LOOKING FOR" TAG
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GlobalColors.primaryColor.withOpacity(0.15),
                        GlobalColors.primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GlobalColors.primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: GlobalColors.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        _getLookingForText(widget.profile),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isLightTheme ? Colors.black87 : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ACTIONS: Like, Share, DM
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        widget.profile['liked_this_profile'] ? Icons.favorite : Icons.favorite_border,
                        color: widget.profile['liked_this_profile'] ? GlobalColors.primaryColor : null,
                      ),
                      onPressed: () async {
                        final nickname = await SharedPreferencesService.getPreference('nickname');
                        setState(() {
                          if (widget.profile['liked_this_profile']) {
                            widget.profile['likes']--;
                            widget.profile['people_liked'].remove(nickname);
                          } else {
                            widget.profile['likes']++;
                            widget.profile['people_liked'].add(nickname);
                          }
                          widget.profile['liked_this_profile'] = !widget.profile['liked_this_profile'];
                        });
                        await ref.read(profileServiceProviderImpl.notifier).likeProfile(widget.profile['id']);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {
                        if (ref.read(permissionProviderImpl)['can_share_profile']) {
                          showMessageRequestModal(context, widget.profile);
                        } else {
                          showPopupComponent(context: context, icon: Icons.error, message: 'Please upgrade your plan');
                        }
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 100,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator(color: GlobalColors.primaryColor, strokeWidth: 2))
                        : ButtonComponent(
                            text: 'DM Me',
                            backgroundColor: GlobalColors.primaryColor,
                            foregroundColor: Colors.white,
                            buttonHeight: 36,
                            buttonWidth: 100,
                            onTap: () => handleDMTap(context),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // LIKES SUMMARY
          if (widget.profile['likes'] > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ExpandableTextComponent(
                text: widget.profile['likes'] == 1
                    ? 'Liked by ${widget.profile['people_liked'][0]}'
                    : 'Liked by ${widget.profile['people_liked'][0]} and others',
              ),
            ),
        ],
      ),
    );
  }
}