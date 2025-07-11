import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:blisso_mobile/components/expandable_text_component.dart';
import 'package:blisso_mobile/screens/chat/attachments/attachment_modal.dart';
import 'package:blisso_mobile/screens/chat/message_options/message_option.dart';
import 'package:blisso_mobile/screens/chat/utils/message_view.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/chat/get_chat_details_provider.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/websocket/websocket_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:routemaster/routemaster.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatViewScreen extends ConsumerStatefulWidget {
  final String username;
  const ChatViewScreen({super.key, required this.username});

  @override
  ConsumerState<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends ConsumerState<ChatViewScreen> {
  //dynamic messages;

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  final TextEditingController messageController = TextEditingController();

  final ValueNotifier<TextEditingController> messageControllerNotifier =
      ValueNotifier<TextEditingController>(TextEditingController());

  final FocusNode textFocusNode = FocusNode();
  ValueNotifier<bool> isEmojiPickerVisible = ValueNotifier(false);

  bool isVoice = true;

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

    if (isSameDay(dateTime, now)) {
      return 'Today, ${timeFormat.format(dateTime)}';
    }

    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (isSameDay(dateTime, yesterday)) {
      return 'Yesterday, ${timeFormat.format(dateTime)}';
    }

    final DateFormat dateFormat = DateFormat("dd/MM/yyyy, hh:mm");
    return dateFormat.format(dateTime);
  }

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    if (await Permission.microphone.isGranted) {
      await _recorder.openRecorder();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission is required")),
      );
    }
  }

  Future<void> _startRecording() async {
    Directory tempDir = Directory.systemTemp;
    String path = "${tempDir.path}/recording.aac";
    await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    String? path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      sendVoiceMessage(path);
    }
  }

  String? username;
  Future<void> getMyUsername() async {
    await SharedPreferencesService.getPreference('username').then((use) {
      setState(() {
        username = use;
      });
    });
  }

  String generateRandomString(int length) {
    final random = Random();
    const availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final randomString = List.generate(length, (index) {
      final randomIndex = random.nextInt(availableChars.length);
      return availableChars[randomIndex];
    }).join();

    return randomString;
  }

  String generate12ByteHexFromTimestamp(DateTime dateTime) {
    // Convert DateTime to Unix timestamp in milliseconds
    int timestamp = dateTime.millisecondsSinceEpoch;

    // Convert timestamp (8 bytes) to hex
    String hexTimestamp = timestamp.toRadixString(16).padLeft(16, '0');

    // Generate 4 random bytes (8 hex characters)
    final random = Random();
    String randomHex = List.generate(
        4, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

    // Combine timestamp + random bytes (12 bytes = 24 hex characters)
    return hexTimestamp + randomHex;
  }

  Future<void> sendTextMessage(String message) async {
    ChatMessageModel messageModel;
    if (editMessage == null) {
      messageModel = ChatMessageModel(
          messageId: generate12ByteHexFromTimestamp(DateTime.now()),
          messageStatus: 'unseen',
          parentId: replyMessage != null
              ? replyMessage['message_id']
              : '000000000000000000000000',
          parentContent: replyMessage != null
              ? replyMessage['content_file_type']
                      .toString()
                      .startsWith('image/')
                  ? 'image'
                  : replyMessage['content_file_type']
                          .toString()
                          .startsWith('video/')
                      ? 'video'
                      : replyMessage['content_file_type']
                              .toString()
                              .startsWith('audio/')
                          ? 'audio'
                          : replyMessage['content']
              : '',
          sender: username!,
          receiver: widget.username,
          action: 'created',
          content: message,
          isFileIncluded: false,
          createdAt: DateTime.now().toUtc().toIso8601String());
    } else {
      messageModel = ChatMessageModel(
          messageId: editMessage['message_id'],
          parentId: editMessage['parent_id'],
          messageStatus: editMessage['message_status'],
          parentContent: editMessage['parent_content'],
          sender: editMessage['sender'],
          receiver: editMessage['receiver'],
          action: 'edited',
          content: message,
          isFileIncluded: editMessage['is_file_included'],
          createdAt: editMessage['created_at']);
    }

    final messageRef = ref.read(webSocketNotifierProvider.notifier);

    messageRef.sendMessage(messageModel);

    final getMessageDetailRef = ref.read(getChatDetailsProviderImpl.notifier);

    if (editMessage == null) {
      getMessageDetailRef.addMessageToChat(messageModel.toMap());
    } else {
      getMessageDetailRef.replaceMessageInChat(messageModel.toMap());
    }

    setState(() {
      editMessage = null;
      replyMessage = null;
    });
  }

  Future<void> sendVoiceMessage(String path) async {
    String extension = path.split('.').last;
    File file = File(path);
    try {
      List<int> bytes = file.readAsBytesSync();
      String base64Bytes = base64Encode(bytes);
      ChatMessageModel messageModel = ChatMessageModel(
          messageId: generate12ByteHexFromTimestamp(DateTime.now()),
          contentFileType: 'audio/$extension',
          messageStatus: 'unseen',
          parentId: replyMessage != null
              ? replyMessage['message_id']
              : '000000000000000000000000',
          parentContent: replyMessage != null
              ? replyMessage['content_file_type']
                      .toString()
                      .startsWith('image/')
                  ? 'image'
                  : replyMessage['content_file_type']
                          .toString()
                          .startsWith('video/')
                      ? 'video'
                      : replyMessage['content_file_type']
                              .toString()
                              .startsWith('audio/')
                          ? 'audio'
                          : replyMessage['content']
              : '',
          contentFile: base64Bytes,
          sender: username!,
          receiver: widget.username,
          action: 'created',
          content: '',
          isFileIncluded: true,
          createdAt: DateTime.now().toUtc().toIso8601String());

      final messageRef = ref.read(webSocketNotifierProvider.notifier);

      messageRef.sendMessage(messageModel);

      final getMessageDetailRef = ref.read(getChatDetailsProviderImpl.notifier);

      getMessageDetailRef.addMessageToChat(messageModel.toMap());

      //Navigator.of(context).pop();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteTextMessage(dynamic deletedMessage) async {
    if (deletedMessage['parent_id'] == '000000000000000000000000') {
      deletedMessage['action'] = 'deleted';

      final messageRef = ref.read(webSocketNotifierProvider.notifier);

      messageRef.sendMessage(ChatMessageModel.fromMap(deletedMessage));

      final getMessageDetailRef = ref.read(getChatDetailsProviderImpl.notifier);

      getMessageDetailRef.removeMessageFromChat(deletedMessage['message_id']);
    }
  }

  final ScrollController scrollController = ScrollController();

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
      );
    }
  }

  final Map<String, GlobalKey> _messageKeys = {};
  void initializeEmptyChat() {
    final chatRef = ref.read(chatServiceProviderImpl);
    final chatNotifier = ref.read(chatServiceProviderImpl.notifier);

    // Check if the chat exists
    bool chatExists = false;
    if (chatRef.data != null) {
      for (var chat in chatRef.data) {
        if (chat['username'] == widget.username) {
          chatExists = true;
          break;
        }
      }
    }

    // If chat doesn't exist, initialize with empty messages
    if (!chatExists) {
      // Create a new list if data is null, otherwise use existing data
      List<Map<String, dynamic>> newData = [];
      if (chatRef.data != null) {
        newData = List.from(chatRef.data);
      }
      chatNotifier.updateMessages(newData);
    }
  }

  bool isNameLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getMyUsername();
      initializeEmptyChat();
      ref.read(getChatDetailsProviderImpl.notifier).markMessagesAsSeen();
      scrollToBottom();
    });
    messageControllerNotifier.value = messageController;
  }

  dynamic replyMessage;

  double dragDistance = 0;

  Map<int, double> dragDistances = {};

  void _scrollToParent(String parentId) {
    final key = _messageKeys[parentId];
    if (key != null) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  

  dynamic deleteMessage;

  dynamic editMessage;

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;


    WidgetsBinding.instance.addPostFrameCallback((_) {
      //ref.read(getChatDetailsProviderImpl.notifier).markMessagesAsSeen();
      scrollToBottom();
      
    });

    final chatDetailsRef = ref.watch(getChatDetailsProviderImpl);

    return SafeArea(
      child: Scaffold(
        backgroundColor:
            isLightTheme ? GlobalColors.lightBackgroundColor : Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: 30,
          backgroundColor:
              isLightTheme ? GlobalColors.lightBackgroundColor : Colors.black,
          leading: Align(
            alignment: Alignment.center,
            child: Container(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: () {
                  Routemaster.of(context).replace('/chat');
                },
                icon: const Icon(
                  Icons.keyboard_arrow_left,
                  size: 20,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 5),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(
                      chatDetailsRef['profile_picture']),
                ),
              ),
              Expanded(
                child: ExpandableTextComponent(
                  text: chatDetailsRef['full_name'],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: chatDetailsRef['messages'].isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet. Start a conversation!',
                        style: TextStyle(
                          color: GlobalColors.secondaryColor,
                        ),
                      ),
                    )
                  : Builder(
                      builder: (context) {
                        // --- BEGIN UNREAD INDICATOR LOGIC ---
                        int unreadCount = 0;
                        int? firstUnreadIndex;
                        for (int i = 0;
                            i < chatDetailsRef['messages'].length;
                            i++) {
                          final msg = chatDetailsRef['messages'][i];
                          if (msg['sender'] != username &&
                              msg['message_status'] == 'unseen') {
                            unreadCount++;
                            firstUnreadIndex ??= i;
                          }
                        }
                        // --- END UNREAD INDICATOR LOGIC ---
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: chatDetailsRef['messages'].length,
                          itemBuilder: (context, index) {
                            final message = chatDetailsRef['messages'][index];
                            final isSender = message['sender'] == username;
                            // Insert unread indicator above the first unread message
                            if (unreadCount > 0 && firstUnreadIndex == index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: GlobalColors.primaryColor
                                                .withOpacity(0.5),
                                            thickness: 1.2,
                                            endIndent: 8,
                                            indent: 8,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: GlobalColors.primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '$unreadCount unread message${unreadCount > 1 ? 's' : ''}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: GlobalColors.primaryColor
                                                .withOpacity(0.5),
                                            thickness: 1.2,
                                            endIndent: 8,
                                            indent: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: isSender
                                        ? const EdgeInsets.only(
                                            top: 1.5,
                                            bottom: 1.5,
                                            left: 80.0,
                                            right: 10)
                                        : const EdgeInsets.only(
                                            top: 1.5,
                                            bottom: 1.5,
                                            left: 10.0,
                                            right: 80),
                                    child: Align(
                                      alignment: isSender
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: GestureDetector(
                                        onLongPress: () {
                                          dynamic selectedMessage = message;
                                          isSender
                                              ? showMessageOption(
                                                  context,
                                                  () => deleteTextMessage(
                                                      selectedMessage), () {
                                                  messageController.text =
                                                      selectedMessage[
                                                          'content'];
                                                  Navigator.of(context).pop();
                                                  setState(() {
                                                    editMessage =
                                                        selectedMessage;
                                                  });
                                                })
                                              : null;
                                        },
                                        onHorizontalDragUpdate: (details) {
                                          setState(() {
                                            dragDistances[index] =
                                                (dragDistances[index] ?? 0) +
                                                    details.primaryDelta!;
                                          });
                                        },
                                        onHorizontalDragEnd: (details) {
                                          if ((dragDistances[index] ?? 0) >
                                              50) {
                                            setState(() {
                                              replyMessage = message;
                                              dragDistances[index] = 0;
                                            });
                                          } else {
                                            setState(() {
                                              dragDistances[index] = 0;
                                            });
                                          }
                                        },
                                        child: Transform.translate(
                                          offset: Offset(
                                              dragDistances[index] ?? 0, 0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5.0,
                                                horizontal: 10.0),
                                            decoration: BoxDecoration(
                                              color: isSender
                                                  ? isLightTheme
                                                      ? GlobalColors
                                                          .myMessageColor
                                                      : GlobalColors
                                                          .primaryColor
                                                  : isLightTheme
                                                      ? Colors.grey[200]
                                                      : GlobalColors
                                                          .otherDarkMessageColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                MessageView(
                                                  message: message,
                                                  scrollToParent:
                                                      _scrollToParent,
                                                  username: widget.username,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: Text(
                                                          formatDate(message[
                                                              'created_at']!),
                                                          textAlign:
                                                              TextAlign.end,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 9),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            // Default message rendering
                            return Padding(
                              padding: isSender
                                  ? const EdgeInsets.only(
                                      top: 1.5,
                                      bottom: 1.5,
                                      left: 80.0,
                                      right: 10)
                                  : const EdgeInsets.only(
                                      top: 1.5,
                                      bottom: 1.5,
                                      left: 10.0,
                                      right: 80),
                              child: Align(
                                alignment: isSender
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: GestureDetector(
                                  onLongPress: () {
                                    dynamic selectedMessage = message;
                                    isSender
                                        ? showMessageOption(
                                            context,
                                            () => deleteTextMessage(
                                                selectedMessage), () {
                                            messageController.text =
                                                selectedMessage['content'];
                                            Navigator.of(context).pop();
                                            setState(() {
                                              editMessage = selectedMessage;
                                            });
                                          })
                                        : null;
                                  },
                                  onHorizontalDragUpdate: (details) {
                                    setState(() {
                                      dragDistances[index] =
                                          (dragDistances[index] ?? 0) +
                                              details.primaryDelta!;
                                    });
                                  },
                                  onHorizontalDragEnd: (details) {
                                    if ((dragDistances[index] ?? 0) > 50) {
                                      setState(() {
                                        replyMessage = message;
                                        dragDistances[index] = 0;
                                      });
                                    } else {
                                      setState(() {
                                        dragDistances[index] = 0;
                                      });
                                    }
                                  },
                                  child: Transform.translate(
                                    offset:
                                        Offset(dragDistances[index] ?? 0, 0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      decoration: BoxDecoration(
                                        color: isSender
                                            ? isLightTheme
                                                ? GlobalColors.myMessageColor
                                                : GlobalColors.primaryColor
                                            : isLightTheme
                                                ? Colors.grey[200]
                                                : GlobalColors
                                                    .otherDarkMessageColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MessageView(
                                            message: message,
                                            scrollToParent: _scrollToParent,
                                            username: widget.username,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Text(
                                                    formatDate(
                                                        message['created_at']!),
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                        fontSize: 9),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
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
                            onEmojiSelected: (category, emoji) {
                              setState(() {
                                isVoice = false;
                              });
                            },
                            textEditingController: messageController,
                            config: Config(
                              height: 256,
                              checkPlatformCompatibility: true,
                              emojiViewConfig: EmojiViewConfig(
                                backgroundColor: isLightTheme
                                    ? GlobalColors.lightBackgroundColor
                                    : Colors.black,
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
                      child: Column(
                        children: [
                          replyMessage == null
                              ? const SizedBox.shrink()
                              : Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  color: isLightTheme
                                      ? Colors.grey[300]
                                      : Colors.grey[800],
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              replyMessage['sender'] == username
                                                  ? 'Me'
                                                  : chatDetailsRef['full_name'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(replyMessage[
                                                        'content_file_type']
                                                    .toString()
                                                    .startsWith('video')
                                                ? 'Video'
                                                : replyMessage[
                                                            'content_file_type']
                                                        .toString()
                                                        .startsWith('audio')
                                                    ? 'Audio'
                                                    : replyMessage[
                                                                'content_file_type']
                                                            .toString()
                                                            .startsWith('file')
                                                        ? 'Document'
                                                        : replyMessage[
                                                            'content'])
                                          ]),
                                      Positioned(
                                        top: -2,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            setState(() {
                                              replyMessage = null;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: toggleEmojiPicker,
                                icon: isVisible
                                    ? const Icon(Icons.keyboard)
                                    : const Icon(Icons.emoji_emotions_outlined),
                              ),
                              IconButton(
                                icon: const Icon(Icons.attachment),
                                onPressed: () => showAttachmentOptions(
                                    context, username!, widget.username),
                              ),
                              Expanded(
                                child: _isRecording
                                    ? const Text('Recording...')
                                    : Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          color: isLightTheme
                                              ? Colors.grey[100]
                                              : Colors.grey[900],
                                        ),
                                        child: ValueListenableBuilder<
                                            TextEditingController>(
                                          valueListenable:
                                              messageControllerNotifier,
                                          builder:
                                              (context, controller, child) {
                                            return TextField(
                                              maxLines: 3,
                                              minLines: 1,
                                              textInputAction:
                                                  TextInputAction.newline,
                                              controller: messageController,
                                              onChanged: (value) {
                                                setState(() {
                                                  isVoice = value.isEmpty;
                                                });
                                              },
                                              focusNode: textFocusNode,
                                              decoration: InputDecoration(
                                                hintText: 'Type a message...',
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                              ),
                                              onTap: () {
                                                isEmojiPickerVisible.value =
                                                    false;
                                              },
                                            );
                                          },
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: GlobalColors.primaryColor,
                                  ),
                                  child: isVoice
                                      ? GestureDetector(
                                          onLongPress: _startRecording,
                                          onLongPressUp: _stopRecording,
                                          child: CircleAvatar(
                                            backgroundColor: _isRecording
                                                ? GlobalColors.primaryColor
                                                : GlobalColors.whiteColor,
                                            child: Icon(Icons.mic,
                                                color: _isRecording
                                                    ? Colors.white
                                                    : GlobalColors
                                                        .primaryColor),
                                          ),
                                        )
                                      : IconButton(
                                          onPressed: () {
                                            final message =
                                                messageController.text.trim();
                                            sendTextMessage(message);

                                            if (message.isNotEmpty) {
                                              messageController.clear();
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                scrollToBottom();
                                              });
                                            }
                                          },
                                          icon: Icon(
                                            color: Colors.white,
                                            isVoice ? Icons.mic : Icons.send,
                                          ),
                                        ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
