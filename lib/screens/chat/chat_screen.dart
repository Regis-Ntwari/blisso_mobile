import 'dart:ui';

import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/chat/attachments/message_request_modal.dart';
import 'package:blisso_mobile/screens/chat/chat_message_request.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/chat/get_chat_details_provider.dart';
import 'package:blisso_mobile/services/permissions/permission_provider.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final List<dynamic> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    
    _searchController.addListener(_filterChats);
    
    // Initialize chat data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChatData();
    });
  }

  bool get _canChat {
    final permissions = ref.read(permissionProviderImpl);
    return permissions['can_chat'] == true;
  }

  bool get _canViewRequests {
    final permissions = ref.read(permissionProviderImpl);
    return permissions['can_view_message_requests'] == true;
  }

  void _initializeChatData() {
    final chatState = ref.read(chatServiceProviderImpl);
    if (chatState.data == null && _canChat) {
      Future(() => _getAllChats());
    } else if (chatState.data != null) {
      _updateFilteredChats(chatState.data!);
    }
  }

  Future<void> _getAllChats() async {
    if (!_canChat) return;
    
    final chatNotifier = ref.read(chatServiceProviderImpl.notifier);
    await chatNotifier.getMessages();
    
    // Update filtered chats after fetch
    final chatData = ref.read(chatServiceProviderImpl).data;
    if (chatData != null) {
      _updateFilteredChats(chatData);
    }
  }

  void _updateFilteredChats(List<dynamic> chats) {
    if (mounted) {
      setState(() {
        _filteredChats
          ..clear()
          ..addAll(chats);
      });
    }
  }

  void _filterChats() {
    final chatData = ref.read(chatServiceProviderImpl).data;
    if (chatData == null) return;

    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      _updateFilteredChats(chatData);
    } else {
      final filtered = chatData.where((chat) {
        final fullName = chat['full_name']?.toString().toLowerCase() ?? '';
        final username = chat['username']?.toString().toLowerCase() ?? '';
        final nickname = chat['nickname']?.toString().toLowerCase() ?? '';

        return fullName.contains(query) ||
            username.contains(query) ||
            nickname.contains(query);
      }).toList();
      
      _updateFilteredChats(filtered);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString).toLocal();
    final now = DateTime.now();
    
    if (_isSameDay(dateTime, now)) {
      return 'Today, ${DateFormat("hh:mm").format(dateTime)}';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(dateTime, yesterday)) {
      return 'Yesterday, ${DateFormat("hh:mm").format(dateTime)}';
    }

    return DateFormat("dd/MM/yyyy, hh:mm").format(dateTime);
  }

  void _chooseChat(
    String username,
    String profilePicture,
    String nickname,
    String fullname,
    List<dynamic>? messages,
  ) {
    if (!_canChat) return;
    
    final chatDetailsNotifier = ref.read(getChatDetailsProviderImpl.notifier);
    chatDetailsNotifier.updateChatDetails({
      'username': username,
      'profile_picture': profilePicture,
      'full_name': fullname,
      'nickname': nickname,
      'messages': messages,
    });
    Routemaster.of(context).push('/chat-detail/$username');
  }

  Future<String> _getChatProfilePicture(String username) async {
    final allUserNotifier = ref.read(allUserServiceProviderImpl.notifier);
    return await allUserNotifier.getProfilePicture(username);
  }

  // Premium overlay widget
  Widget _buildPremiumOverlay({
    required Widget child,
    required String message,
    bool showUpgradeButton = true,
  }) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Blurred content
        IgnorePointer(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.grey.withOpacity(0.5),
              BlendMode.srcATop,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: child,
            ),
          ),
        ),
        
        // Overlay message
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: isDarkTheme 
                  ? Colors.grey[900]!.withOpacity(0.9) 
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium,
                  size: 50,
                  color: GlobalColors.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkTheme ? Colors.white : Colors.grey[800],
                  ),
                ),
                if (showUpgradeButton) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Routemaster.of(context).replace('/homepage'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30, 
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Go to profile to upgrade Plan'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, top: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          color: isLightTheme ? Colors.grey[100] : Colors.grey[900],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for chats...',
            contentPadding: const EdgeInsets.symmetric(
              vertical: 1, 
              horizontal: 15,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(60)),
              borderSide: BorderSide.none,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildChatListItem(Map<String, dynamic> chat) {
    final profilePicture = chat['profile_picture_url'] ?? '';
    final nickname = chat['nickname'] ?? '';
    final fullname = chat['full_name'] ?? '';
    final username = chat['username'] ?? '';
    final messages = chat['messages'];
    
    final lastMessage = _getLastMessage(messages, username);
    final hasUnread = _hasUnreadMessage(lastMessage, username);

    return InkWell(
      onTap: () => _chooseChat(username, profilePicture, nickname, fullname, messages),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(profilePicture),
        ),
        title: Text(fullname),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _truncateMessage(lastMessage['content']),
                style: TextStyle(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(lastMessage['created_at']),
              style: TextStyle(
                fontSize: 10,
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getLastMessage(List<dynamic>? messages, String username) {
    if (messages == null || messages.isEmpty) {
      return {
        'content': 'No messages yet',
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'sender': username,
        'message_status': 'seen',
      };
    }
    
    return messages.last;
  }

  bool _hasUnreadMessage(Map<String, dynamic> lastMessage, String username) {
    return lastMessage['sender'] != username &&
        lastMessage['message_status'] == 'unseen';
  }

  String _truncateMessage(String message) {
    const maxLength = 30;
    return message.length > maxLength 
        ? '${message.substring(0, maxLength)}...' 
        : message;
  }

  Widget _buildChatListContent() {
    final chatState = ref.watch(chatServiceProviderImpl);

    if (chatState.isLoading) {
      return const LoadingScreen();
    }
    
    if (!_canChat) {
      return _buildPremiumOverlay(
        child: Column(
          children: [
            _buildSearchField(),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => const _ChatListItemSkeleton(),
              ),
            ),
          ],
        ),
        message: 'Upgrade your plan to unlock chat features',
      );
    }
    
    final chatData = chatState.data;
    if (chatData == null || chatData.isEmpty) {
      return _buildPremiumOverlay(
        child: Column(
          children: [
            _buildSearchField(),
            Expanded(
              child: Center(
                child: Text(
                  'No chats yet',
                  style: TextStyle(color: GlobalColors.secondaryColor),
                ),
              ),
            ),
          ],
        ),
        message: 'Start conversations with other users.',
        showUpgradeButton: false,
      );
    }
    
    // Initialize filtered chats if empty
    if (_filteredChats.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateFilteredChats(chatData);
      });
    }
    
    return Column(
      children: [
        _buildSearchField(),
        Expanded(
          child: _filteredChats.isEmpty
              ? Center(
                  child: Text(
                    'No matching chats found',
                    style: TextStyle(color: GlobalColors.secondaryColor),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredChats.length,
                  itemBuilder: (context, index) => 
                      _buildChatListItem(_filteredChats[index]),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scaler = MediaQuery.textScalerOf(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? GlobalColors.lightBackgroundColor 
            : Colors.black,
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white 
              : Colors.black,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Routemaster.of(context).replace('/homepage'),
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
              _buildChatListContent(),
              
              // Second tab - Message Requests
              !_canViewRequests
                  ? _buildPremiumOverlay(
                      child: const ChatMessageRequest(),
                      message: 'Upgrade your plan to view message requests',
                    )
                  : const ChatMessageRequest(),
            ],
          ),
        ),
        floatingActionButton: _canChat
            ? InkWell(
                onTap: () => showMessageRequestModal(context, null),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: GlobalColors.primaryColor,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.add,
                      color: GlobalColors.whiteColor,
                      size: 40,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

// Skeleton loading widget for chat list items
class _ChatListItemSkeleton extends StatelessWidget {
  const _ChatListItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: CircleAvatar(backgroundColor: Colors.grey),
      title: SizedBox(
        height: 16,
        width: 120,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.grey),
        ),
      ),
      subtitle: SizedBox(
        height: 12,
        width: 180,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.grey),
        ),
      ),
    );
  }
}