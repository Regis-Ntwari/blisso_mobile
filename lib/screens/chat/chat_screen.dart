import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/chat/attachments/message_request_modal.dart';
import 'package:blisso_mobile/screens/chat/chat_message_request.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/services/users/all_user_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with AutomaticKeepAliveClientMixin {
  dynamic getUserFromUsername(String username) async {
    final profileRef = ref.read(profileServiceProviderImpl.notifier);

    await profileRef.getAnyProfile(username);

    final profileData = ref.read(profileServiceProviderImpl);

    return profileData.data;
  }

  void getAllChats() async {
    final chatRef = ref.watch(chatServiceProviderImpl.notifier);

    await chatRef.getMessages();
  }

  final TextEditingController searchController = TextEditingController();

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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

  void chooseChat(String username) {
    final chatRef = ref.read(chatServiceProviderImpl);
    for (Map<dynamic, dynamic> chat in chatRef.data) {
      if (chat.containsKey(username)) {
        Routemaster.of(context).push('/chat-detail/$username');
      }
    }
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(chatServiceProviderImpl).data == null) {
        Future(() => getAllChats()); // Fetch only if data is null
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final chatRef = ref.watch(chatServiceProviderImpl);

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          backgroundColor:
              isLightTheme ? GlobalColors.lightBackgroundColor : Colors.black,
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Routemaster.of(context).replace('/homepage');
              },
              icon: const Icon(Icons.keyboard_arrow_left),
            ),
            title: Text(
              'Chat',
              style: TextStyle(
                fontSize: scaler.scale(24),
                color: GlobalColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: const TabBar(
              indicatorColor: GlobalColors.primaryColor,
              labelStyle: TextStyle(color: GlobalColors.primaryColor),
              tabs: [
                Tab(text: "Chats"),
                Tab(text: "Message Requests"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // First tab - Chat List
              chatRef.isLoading
                  ? const LoadingScreen()
                  : chatRef.data == null || chatRef.data.isEmpty
                      ? Center(
                          child: Text(
                            'No chats yet',
                            style:
                                TextStyle(color: GlobalColors.secondaryColor),
                          ),
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10, top: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60),
                                  color: isLightTheme
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                ),
                                child: TextField(
                                  controller: searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search for chats...',
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 1, horizontal: 15),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(60)),
                                        borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  String username =
                                      chatRef.data[index].keys.first;
                                  List<dynamic>? messages =
                                      chatRef.data[index][username];
                                  Map<String, dynamic> lastMessage = {};

                                  if (messages != null && messages.isNotEmpty) {
                                    lastMessage = messages[messages.length - 1];
                                  } else {
                                    lastMessage = {
                                      'content': 'No messages yet',
                                      'created_at': DateTime.now()
                                          .toUtc()
                                          .toIso8601String()
                                    };
                                  }

                                  return InkWell(
                                    onTap: () => chooseChat(username),
                                    child: ListTile(
                                      leading: FutureBuilder<String>(
                                        future: Future(() =>
                                            getChatProfilePicture(username)),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircleAvatar(
                                              backgroundColor: Colors.grey,
                                              child: CircularProgressIndicator(
                                                color:
                                                    GlobalColors.primaryColor,
                                              ),
                                            );
                                          } else if (snapshot.hasError ||
                                              !snapshot.hasData) {
                                            return const CircleAvatar(
                                              backgroundColor: Colors.grey,
                                              child: Icon(Icons.person,
                                                  color: Colors.white),
                                            );
                                          } else {
                                            return CircleAvatar(
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      snapshot.data!),
                                            );
                                          }
                                        },
                                      ),
                                      title: FutureBuilder<String>(
                                        future: Future(
                                            () => getChatFullName(username)),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text('Loading...');
                                          } else if (snapshot.hasError ||
                                              !snapshot.hasData) {
                                            return const Text('Unknown User');
                                          } else {
                                            return Text(snapshot.data!);
                                          }
                                        },
                                      ),
                                      subtitle: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            lastMessage['content']
                                                        .toString()
                                                        .length >
                                                    30
                                                ? '${lastMessage['content'].toString().characters.take(30)}...'
                                                : lastMessage['content']
                                                    .toString(),
                                          ),
                                          Text(
                                            formatDate(lastMessage['created_at']
                                                .toString()),
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                itemCount: chatRef.data.length,
                              ),
                            ),
                          ],
                        ),

              // Second tab - Placeholder for other details
              // const Center(
              //   child: Text(
              //     'Other details will go here',
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //   ),
              // ),
              const ChatMessageRequest()
            ],
          ),
          floatingActionButton: InkWell(
            onTap: () {
              showMessageRequestModal(context);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                color: GlobalColors.primaryColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.add,
                  color: GlobalColors.whiteColor,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
