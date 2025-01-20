import 'dart:io';

import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatViewScreen extends ConsumerStatefulWidget {
  final String username;
  const ChatViewScreen({super.key, required this.username});

  static final messages = [
    {
      "message_id": "678411084e42a3d29f83637b",
      "content":
          "How are you doing there? I am okay and well. We should meet these times and work together",
      "sender": "ishimwehope@gmail.com",
      "receiver": "niyibizischadrack@gmail.com",
      "sender_receiver": "ishimwehope@gmail.com_niyibizischadrack@gmail.com",
      "created_at": "2025-01-12T18:59:20.114Z"
    },
    {
      "message_id": "678410f94e42a3d29f836379",
      "content":
          "I'm doing great! How about you?... you are very good I see... You have a lot of work to do",
      "sender": "niyibizischadrack@gmail.com",
      "receiver": "ishimwehope@gmail.com",
      "sender_receiver": "niyibizischadrack@gmail.com_ishimwehope@gmail.com",
      "created_at": "2025-01-12T19:00:05.666Z"
    },
    {
      "message_id": "678411084e42a3d29f83637b",
      "content":
          "How are you doing there? I am okay and well. We should meet these times and work together",
      "sender": "ishimwehope@gmail.com",
      "receiver": "niyibizischadrack@gmail.com",
      "sender_receiver": "ishimwehope@gmail.com_niyibizischadrack@gmail.com",
      "created_at": "2025-01-12T18:59:20.114Z"
    },
    {
      "message_id": "678410f94e42a3d29f836379",
      "content":
          "I'm doing great! How about you?... you are very good I see... You have a lot of work to do",
      "sender": "niyibizischadrack@gmail.com",
      "receiver": "ishimwehope@gmail.com",
      "sender_receiver": "niyibizischadrack@gmail.com_ishimwehope@gmail.com",
      "created_at": "2025-01-12T19:00:05.666Z"
    },
    {
      "message_id": "678411084e42a3d29f83637b",
      "content":
          "How are you doing there? I am okay and well. We should meet these times and work together",
      "sender": "ishimwehope@gmail.com",
      "receiver": "niyibizischadrack@gmail.com",
      "sender_receiver": "ishimwehope@gmail.com_niyibizischadrack@gmail.com",
      "created_at": "2025-01-13T18:59:20.114Z"
    },
    {
      "message_id": "678410f94e42a3d29f836379",
      "content":
          "I'm doing great! How about you?... you are very good I see... You have a lot of work to do",
      "sender": "niyibizischadrack@gmail.com",
      "receiver": "ishimwehope@gmail.com",
      "sender_receiver": "niyibizischadrack@gmail.com_ishimwehope@gmail.com",
      "created_at": "2025-01-13T19:00:05.666Z"
    },
  ];

  @override
  ConsumerState<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends ConsumerState<ChatViewScreen> {
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  final TextEditingController messageController = TextEditingController();

  final FocusNode textFocusNode = FocusNode();
  ValueNotifier<bool> isEmojiPickerVisible = ValueNotifier(false);

  File? pickedImage;
  File? takenPicture;

  void toggleEmojiPicker() {
    isEmojiPickerVisible.value = !isEmojiPickerVisible.value;
    if (isEmojiPickerVisible.value) {
      textFocusNode.unfocus();
    } else {
      textFocusNode.requestFocus();
    }
  }

  String formatDate(String dateTimeString) {
    final DateTime dateTime = DateTime.parse(dateTimeString);
    final DateTime now = DateTime.now();
    final DateFormat timeFormat = DateFormat("hh:mm");

    // Check if the date is today
    if (isSameDay(dateTime, now)) {
      return 'Today, ${timeFormat.format(dateTime)}';
    }

    // Check if the date is yesterday
    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (isSameDay(dateTime, yesterday)) {
      return 'Yesterday, ${timeFormat.format(dateTime)}';
    }

    // Otherwise, return the date in the format dd/MM/yyyy, hh:mm
    final DateFormat dateFormat = DateFormat("dd/MM/yyyy, hh:mm");
    return dateFormat.format(dateTime);
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      pickedImage = File(pickedFile.path);
                    });
                    _showImageWithCaption(context, pickedImage!);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a Picture"),
                onTap: () async {
                  // Close the bottom sheet
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      takenPicture = File(pickedFile.path);
                    });
                    _showImageWithCaption(context, takenPicture!);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageWithCaption(BuildContext context, File image) {
    TextEditingController captionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     // Handle the submission of the image and caption
                  //     final caption = captionController.text.trim();
                  //     print("Image Path: ${image.path}");
                  //     print("Caption: $caption");
                  //     Navigator.pop(context); // Close the bottom sheet
                  //   },
                  //   child: const Text("Send"),
                  // ),
                ],
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.file(
                  image,
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: captionController,
                        maxLines: 2,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: "Add a caption...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.send,
                          color: GlobalColors.primaryColor,
                        ))
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileRef = ref.read(profileServiceProviderImpl.notifier);

    String? fullnames = profileRef.getFullName(widget.username);

    String? profilePicture = profileRef.getProfilePicture(widget.username);

    bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(profilePicture!),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(fullnames!)),
            ],
          ),
          leading: IconButton(
            onPressed: () {
              Routemaster.of(context).replace('/chat');
            },
            icon: const Icon(Icons.keyboard_arrow_left),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: ChatViewScreen.messages.length,
                itemBuilder: (context, index) {
                  final message = ChatViewScreen.messages[index];
                  final isSender =
                      message['sender'] == 'niyibizischadrack@gmail.com';

                  return Padding(
                    padding: isSender
                        ? const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 40.0, right: 10)
                        : const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 10.0, right: 40),
                    child: Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: isSender
                              ? isLightTheme
                                  ? GlobalColors.myMessageColor
                                  : GlobalColors.primaryColor
                              : isLightTheme
                                  ? Colors.grey[200]
                                  : GlobalColors.otherDarkMessageColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSender ? "Me" : fullnames,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isLightTheme
                                    ? Colors.black54
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              message['content']!,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                formatDate(message['created_at']!),
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isEmojiPickerVisible,
              builder: (context, isVisible, child) {
                return Column(
                  children: [
                    if (isVisible)
                      SizedBox(
                          height: 250,
                          child: EmojiPicker(
                            onBackspacePressed: () {},
                            textEditingController:
                                messageController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                            config: Config(
                              height: 256,
                              checkPlatformCompatibility: true,
                              emojiViewConfig: EmojiViewConfig(
                                backgroundColor: isLightTheme
                                    ? GlobalColors.lightBackgroundColor
                                    : Colors.black,
                                // Issue: https://github.com/flutter/flutter/issues/28894
                                emojiSizeMax: 28 *
                                    (foundation.defaultTargetPlatform ==
                                            TargetPlatform.iOS
                                        ? 1.20
                                        : 1.0),
                              ),
                              viewOrderConfig: const ViewOrderConfig(
                                top: EmojiPickerItem.searchBar,
                                middle: EmojiPickerItem.categoryBar,
                                bottom: EmojiPickerItem.emojiView,
                              ),
                              skinToneConfig: const SkinToneConfig(),
                              categoryViewConfig: CategoryViewConfig(
                                  indicatorColor: GlobalColors.primaryColor,
                                  iconColorSelected: GlobalColors.primaryColor,
                                  backgroundColor: isLightTheme
                                      ? GlobalColors.lightBackgroundColor
                                      : Colors.black),
                              bottomActionBarConfig: BottomActionBarConfig(
                                  enabled: false,
                                  buttonColor: GlobalColors.primaryColor,
                                  backgroundColor: isLightTheme
                                      ? GlobalColors.lightBackgroundColor
                                      : Colors.black),
                              searchViewConfig: SearchViewConfig(
                                  backgroundColor: isLightTheme
                                      ? GlobalColors.lightBackgroundColor
                                      : Colors.black),
                            ),
                          )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 5),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: toggleEmojiPicker,
                            icon: isVisible
                                ? const Icon(Icons.keyboard)
                                : const Icon(Icons.emoji_emotions_outlined),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attachment),
                            onPressed: () => _showAttachmentOptions(context),
                          ),
                          Expanded(
                            child: TextField(
                              maxLines: 4,
                              minLines: 1,
                              textInputAction: TextInputAction.newline,
                              controller: messageController,
                              focusNode: textFocusNode,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15),
                              ),
                              onTap: () {
                                isEmojiPickerVisible.value = false;
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Send message logic
                              final message = messageController.text.trim();
                              if (message.isNotEmpty) {
                                messageController.clear();
                              }
                            },
                            icon: const Icon(Icons.send,
                                color: GlobalColors.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        // bottomSheet: Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: TextField(
        //           decoration: InputDecoration(
        //             hintText: 'Type a message...',
        //             border: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(30),
        //               borderSide: const BorderSide(color: Colors.grey),
        //             ),
        //             contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        //           ),
        //         ),
        //       ),
        //       IconButton(
        //         onPressed: () {
        //           // Add functionality to send a message
        //         },
        //         icon: const Icon(Icons.send, color: GlobalColors.primaryColor),
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
