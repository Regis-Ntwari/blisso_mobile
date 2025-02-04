import 'dart:io';
import 'dart:math';

import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/users/all_user_service_provider.dart';
import 'package:blisso_mobile/services/websocket/websocket_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
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
  dynamic messages;

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
    await _recorder.startRecorder(toFile: path);
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
      // Send or handle the recorded audio file
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Audio saved at $path")),
      );
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    showModalBottomSheet(
      constraints: BoxConstraints(maxHeight: 200, maxWidth: width * 0.8),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                pickedImage = File(pickedFile.path);
                              });
                              _showImageWithCaption(context, pickedImage!);
                            }
                          },
                          child: const CircleAvatar(
                            child: Icon(Icons.photo),
                          ),
                        ),
                        const Text('Photo')
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickVideo(
                                source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                pickedImage = File(pickedFile.path);
                              });
                              _showImageWithCaption(context, pickedImage!);
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: GlobalColors.secondaryColor,
                            child: const Icon(Icons.video_collection),
                          ),
                        ),
                        const Text('Video')
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['mp3', 'wav', 'mp4']);

                            if (result != null) {
                              File files = File(result.files.single.path!);
                              print(files.path);
                              PlatformFile file = result.files.first;

                              print(file.name);
                              print(file.bytes);
                              print(file.size);
                              print(file.extension);
                              print(file.path);
                            } else {
                              // User canceled the picker
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.green[700],
                            child: const Icon(Icons.audio_file),
                          ),
                        ),
                        const Text('Audio')
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: [
                                  'pdf',
                                  'doc',
                                  'docx',
                                  'pptx',
                                  'ppt',
                                  'xlsx',
                                  'xls',
                                  'xml',
                                ]);

                            if (result != null) {
                              File files = File(result.files.single.path!);
                              print(files.path);
                              PlatformFile file = result.files.first;

                              print(file.name);
                              print(file.bytes);
                              print(file.size);
                              print(file.extension);
                              print(file.path);
                            } else {
                              // User canceled the picker
                            }
                          },
                          child: const CircleAvatar(
                            backgroundColor: GlobalColors.primaryColor,
                            child: Icon(Icons.file_copy),
                          ),
                        ),
                        const Text('Document')
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(
                                source: ImageSource.camera);
                            if (pickedFile != null) {
                              setState(() {
                                takenPicture = File(pickedFile.path);
                              });
                              _showImageWithCaption(context, takenPicture!);
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.blue[700],
                            child: const Icon(Icons.camera_alt),
                          ),
                        ),
                        const Text('Take Picture')
                      ],
                    )
                  ],
                )
              ],
            ),
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
        return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
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
                    ],
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Flexible(
                      child: Image.file(
                        image,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60)),
                                  borderSide: BorderSide.none),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
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
                ],
              ),
            ),
          );
        });
      },
    );
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
    ChatMessageModel messageModel = ChatMessageModel(
        messageId: generate12ByteHexFromTimestamp(DateTime.now()),
        sender: username!,
        receiver: widget.username,
        action: 'created',
        content: message,
        isFileIncluded: false,
        createdAt: DateTime.now().toUtc().toIso8601String());

    final messageRef = ref.read(webSocketNotifierProvider.notifier);

    messageRef.sendMessage(messageModel);
  }

  Future<String> getChatFullName(String username) async {
    final allUserRef = ref.read(allUserServiceProviderImpl.notifier);

    String fullname = await allUserRef.getFullName(username);

    return fullname;
  }

  Future<String> getChatProfilePicture(String username) async {
    final allUserRef = ref.read(allUserServiceProviderImpl.notifier);

    String fullname = await allUserRef.getProfilePicture(username);

    return fullname;
  }

  final ScrollController scrollController = ScrollController();

  void scrollToBottom() {
    if (scrollController.hasClients) {
      print(scrollController.position.maxScrollExtent);
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getMyUsername();
      scrollToBottom();
    });
    messageControllerNotifier.value = messageController;
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    final chatRef = ref.watch(chatServiceProviderImpl);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });

    dynamic messages;

    for (var chat in chatRef.data) {
      if (chat.containsKey(widget.username)) {
        messages = chat[widget.username];
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: 40,
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
              FutureBuilder<String>(
                future: Future(() => getChatProfilePicture(widget.username)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    );
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    );
                  } else {
                    return CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(snapshot.data!),
                    );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: FutureBuilder<String>(
                  future: Future(() => getChatFullName(widget.username)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading...');
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('Unknown User');
                    } else {
                      return Text(
                        snapshot.data!,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        body: username == null
            ? const LoadingScreen()
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages![index];
                        final isSender = message['sender'] == username;
                        return Padding(
                          padding: isSender
                              ? const EdgeInsets.only(
                                  top: 1.5, bottom: 1.5, left: 40.0, right: 10)
                              : const EdgeInsets.only(
                                  top: 1.5, bottom: 1.5, left: 10.0, right: 40),
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text(
                                  //   isSender ? "Me" : fullnames!,
                                  //   style: TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //     fontSize: 12,
                                  //     color: isLightTheme
                                  //         ? Colors.black54
                                  //         : Colors.white,
                                  //   ),
                                  // ),
                                  const SizedBox(height: 3),
                                  Text(
                                    message['content']!,
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      formatDate(message['created_at']!),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(fontSize: 9),
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
                                        indicatorColor:
                                            GlobalColors.primaryColor,
                                        iconColorSelected:
                                            GlobalColors.primaryColor,
                                        backgroundColor: isLightTheme
                                            ? GlobalColors.lightBackgroundColor
                                            : Colors.black),
                                    bottomActionBarConfig:
                                        BottomActionBarConfig(
                                            enabled: false,
                                            buttonColor:
                                                GlobalColors.primaryColor,
                                            backgroundColor: isLightTheme
                                                ? GlobalColors
                                                    .lightBackgroundColor
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
                                      : const Icon(
                                          Icons.emoji_emotions_outlined),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.attachment),
                                  onPressed: () =>
                                      _showAttachmentOptions(context),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      color: isLightTheme
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                    ),
                                    child: ValueListenableBuilder<
                                        TextEditingController>(
                                      valueListenable:
                                          messageControllerNotifier,
                                      builder: (context, controller, child) {
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
                                                    BorderRadius.circular(60)),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 15),
                                          ),
                                          onTap: () {
                                            isEmojiPickerVisible.value = false;
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
