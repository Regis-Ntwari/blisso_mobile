import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  dynamic getUserFromUsername(String username) async {
    final profileRef = ref.read(profileServiceProviderImpl.notifier);

    await profileRef.getAnyProfile(username);

    final profileData = ref.read(profileServiceProviderImpl);

    return profileData.data;
  }

  final _chats = [
    {
      "niyibizischadrack05@gmail.com": [
        {
          "message_id": "678411084e42a3d29f83637b",
          "content": "How are you doing there?",
          "sender": "ishimwehope@gmail.com",
          "receiver": "niyibizischadrack@gmail.com",
          "sender_receiver":
              "ishimwehope@gmail.com_niyibizischadrack@gmail.com",
          "created_at": "2025-01-12T18:59:20.114Z"
        },
        {
          "message_id": "678410f94e42a3d29f836379",
          "content": "Good morning Schadrack!",
          "sender": "ishimwehope@gmail.com",
          "receiver": "niyibizischadrack@gmail.com",
          "sender_receiver":
              "ishimwehope@gmail.com_niyibizischadrack@gmail.com",
          "created_at": "2025-01-12T18:59:05.666Z"
        },
        {
          "message_id": "678410d24e42a3d29f836377",
          "content": "Good morning Hope!",
          "sender": "niyibizischadrack@gmail.com",
          "receiver": "ishimwehope@gmail.com",
          "sender_receiver":
              "niyibizischadrack@gmail.com_ishimwehope@gmail.com",
          "created_at": "2025-01-12T18:58:26.283Z"
        }
      ]
    },
    {
      "regis.ntwari.danny@gmail.com": [
        {
          "message_id": "678410b14e42a3d29f836375",
          "content": "Good morning Georges!",
          "sender": "niyibizischadrack@gmail.com",
          "receiver": "nishimwegeorges@gmail.com",
          "sender_receiver":
              "niyibizischadrack@gmail.com_nishimwegeorges@gmail.com",
          "created_at": "2025-01-12T18:57:53.704Z"
        }
      ]
    },
    {
      "atrack1998@gmail.com": [
        {
          "message_id": "678410844e42a3d29f836373",
          "content": "Good morning Williams!",
          "sender": "niyibizischadrack@gmail.com",
          "receiver": "williamspeterson@gmail.com",
          "sender_receiver":
              "niyibizischadrack@gmail.com_williamspeterson@gmail.com",
          "created_at": "2025-01-12T18:57:08.162Z"
        }
      ]
    }
  ];
  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final profileRef = ref.read(profileServiceProviderImpl.notifier);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Routemaster.of(context).replace('/homepage');
            },
            icon: const Icon(Icons.keyboard_arrow_left)),
        title: Text(
          'Chat',
          style: TextStyle(
              fontSize: scaler.scale(24),
              color: GlobalColors.primaryColor,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                String username = _chats[index].keys.first;
                Map<String, String> lastMessage = _chats[index].values.first[0];
                String? names = profileRef.getFullName(username);
                String? profilePicture = profileRef.getProfilePicture(username);
                return InkWell(
                  onTap: () {
                    Routemaster.of(context).push('/chat-detail/$username');
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(profilePicture!),
                    ),
                    title: Text(
                      names!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(lastMessage['content']!),
                  ),
                );
              },
              itemCount: _chats.length,
            ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                color: GlobalColors.primaryColor),
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.add,
                  color: GlobalColors.whiteColor,
                  size: 40,
                )),
          )),
    ));
  }
}
