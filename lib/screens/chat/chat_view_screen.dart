import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';

class ChatViewScreen extends ConsumerWidget {
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

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
                title: const Text("Choose Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    // Handle the selected image
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Picture"),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    // Handle the captured image
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text("Choose File"),
                onTap: () async {
                  Navigator.pop(context);
                  // final result = await FilePicker.platform.pickFiles();
                  // if (result != null) {
                  //   // Handle the selected file
                  // }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileRef = ref.read(profileServiceProviderImpl.notifier);

    String? fullnames = profileRef.getFullName(username);

    String? profilePicture = profileRef.getProfilePicture(username);

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
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
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
                              isSender ? "You" : fullnames,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        _showAttachmentOptions(context);
                      },
                      icon: const Icon(Icons.attachment)),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Add functionality to send a message
                    },
                    icon: const Icon(Icons.send,
                        color: GlobalColors.primaryColor),
                  ),
                ],
              ),
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
