import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/chat/attachments/message_request_modal.dart';
import 'package:blisso_mobile/screens/chat/chat_message_request.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/chat/get_chat_details_provider.dart';
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
  List<dynamic> filteredChats = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(chatServiceProviderImpl).data == null) {
        Future(() => getAllChats()); // Fetch only if data is null
      }
    });
    
    // Add listener to search controller
    searchController.addListener(() {
      filterChats();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterChats() {
    final chatRef = ref.read(chatServiceProviderImpl);
    final query = searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        filteredChats = chatRef.data ?? [];
      });
    } else {
      setState(() {
        filteredChats = (chatRef.data ?? []).where((chat) {
          final fullName = chat['full_name']?.toString().toLowerCase() ?? '';
          final username = chat['username']?.toString().toLowerCase() ?? '';
          final nickname = chat['nickname']?.toString().toLowerCase() ?? '';
          
          return fullName.contains(query) || 
                 username.contains(query) || 
                 nickname.contains(query);
        }).toList();
      });
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String formatDate(String dateTimeString) {
    final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
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

  void chooseChat(String username, String profilePicture, String nickname,
      String fullname, List<dynamic>? messages) {
    final chatDetailsRef = ref.read(getChatDetailsProviderImpl.notifier);
    chatDetailsRef.updateChatDetails({
      'username': username,
      'profile_picture': profilePicture,
      'full_name': fullname,
      'nickname': nickname,
      'messages': messages
    });
    Routemaster.of(context).push('/chat-detail/$username');
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
  Widget build(BuildContext context) {
    super.build(context);
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final chatRef = ref.watch(chatServiceProviderImpl);
    
    // Initialize filteredChats if empty and chat data is available
    if (filteredChats.isEmpty && chatRef.data != null) {
      filteredChats = chatRef.data!;
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            isLightTheme ? GlobalColors.lightBackgroundColor : Colors.black,
        appBar: AppBar(
          backgroundColor: isLightTheme ? Colors.white : Colors.black,
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
        body: SafeArea(
          child: TabBarView(
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
                                  decoration: InputDecoration(
                                    hintText: 'Search for chats...',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 1, horizontal: 15),
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(60)),
                                        borderSide: BorderSide.none),
                                    suffixIcon: searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              searchController.clear();
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: filteredChats.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No matching chats found',
                                        style: TextStyle(
                                            color: GlobalColors.secondaryColor),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemBuilder: (context, index) {
                                        String profilePicture = filteredChats[index]
                                            ['profile_picture_url'];
                                        String nickname =
                                            filteredChats[index]['nickname'];
                                        String fullname =
                                            filteredChats[index]['full_name'];
                                        String username =
                                            filteredChats[index]['username'];
                                        List<dynamic>? messages =
                                            filteredChats[index]['messages'];
                                        Map<String, dynamic> lastMessage = {};
                    
                                        if (messages != null && messages.isNotEmpty) {
                                          lastMessage = messages[messages.length - 1];
                                          print(lastMessage);
                                        } else {
                                          lastMessage = {
                                            'content': 'No messages yet',
                                            'created_at': DateTime.now()
                                                .toUtc()
                                                .toIso8601String()
                                          };
                                        }
                    
                                        return InkWell(
                                          onTap: () => chooseChat(
                                              username,
                                              profilePicture,
                                              nickname,
                                              fullname,
                                              messages),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      profilePicture),
                                            ),
                                            title: Text(fullname),
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
                                                          style: TextStyle(fontWeight: lastMessage[
                                                                      'sender'] !=
                                                                  username &&
                                                              lastMessage[
                                                                      'message_status'] ==
                                                                  'unseen'
                                                          ? FontWeight.bold
                                                          : FontWeight.normal),
                                                ),
                                                Text(
                                                  formatDate(lastMessage['created_at']
                                                      .toString()),
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: lastMessage[
                                                                      'sender'] !=
                                                                  username &&
                                                              lastMessage[
                                                                      'message_status'] ==
                                                                  'unseen'
                                                          ? FontWeight.bold
                                                          : FontWeight.normal),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: filteredChats.length,
                                    ),
                            ),
                          ],
                        ),
              const ChatMessageRequest()
            ],
          ),
        ),
        floatingActionButton: InkWell(
          onTap: () {
            showMessageRequestModal(context, null);
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}