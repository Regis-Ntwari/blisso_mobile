import 'package:blisso_mobile/services/message_requests/message_request_service_provider.dart';
import 'package:blisso_mobile/services/users/all_user_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class MessageRequestModal extends ConsumerStatefulWidget {
  const MessageRequestModal({super.key});

  @override
  ConsumerState<MessageRequestModal> createState() =>
      _MessageRequestModalState();
}

class _MessageRequestModalState extends ConsumerState<MessageRequestModal> {
  TextEditingController searchController = TextEditingController();

  Future<void> getUsers() async {
    final messageRequestRef =
        ref.read(messageRequestServiceProviderImpl.notifier);

    await messageRequestRef.mapApprovedUsers();
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
      getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    double height = MediaQuery.sizeOf(context).height;
    final messageRequestRef = ref.watch(messageRequestServiceProviderImpl);
    return SizedBox(
      height: height * 0.9,
      child: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: messageRequestRef.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: GlobalColors.primaryColor,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close)),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, right: 10, top: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        color:
                            isLightTheme ? Colors.grey[100] : Colors.grey[900],
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search for users...',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 1, horizontal: 15),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(60)),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                    itemCount: messageRequestRef.data.keys.length,
                    itemBuilder: (context, index) {
                      final usersList = messageRequestRef.data.keys.toList();
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Routemaster.of(context)
                              .push('/chat-detail/${usersList[index]}');
                        },
                        child: ListTile(
                          leading: FutureBuilder<String>(
                            future: Future(
                                () => getChatProfilePicture(usersList[index])),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  child: CircularProgressIndicator(
                                    color: GlobalColors.primaryColor,
                                  ),
                                );
                              } else if (snapshot.hasError ||
                                  !snapshot.hasData) {
                                return const CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  child:
                                      Icon(Icons.person, color: Colors.white),
                                );
                              } else {
                                return CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      snapshot.data!),
                                );
                              }
                            },
                          ),
                          title: FutureBuilder<String>(
                            future:
                                Future(() => getChatFullName(usersList[index])),
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
                        ),
                      );
                    },
                  ))
                ],
              ),
      )),
    );
  }
}

void showMessageRequestModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return const MessageRequestModal();
    },
  );
}
