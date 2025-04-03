import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageRequestModal extends ConsumerStatefulWidget {
  const MessageRequestModal({super.key});

  @override
  ConsumerState<MessageRequestModal> createState() =>
      _MessageRequestModalState();
}

class _MessageRequestModalState extends ConsumerState<MessageRequestModal> {
  TextEditingController searchController = TextEditingController();

  Future<void> getUsers() async {}

  final users = [
    {
      'id': 1,
      'username': 'rex90danny@gmail.com',
      'profile_picture_uri':
          'https://images.unsplash.com/photo-1742201835840-1325b7546403',
      'names': 'Regis Ntwari'
    },
    {
      'id': 2,
      'username': 'niyibizischadrack@gmail.com',
      'profile_picture_uri':
          'https://images.unsplash.com/photo-1741732311526-093a69d005d9',
      'names': 'Schadrack Niyibizi'
    },
    {
      'id': 1,
      'username': 'horanituzejocelyne@gmail.com',
      'profile_picture_uri':
          'https://images.unsplash.com/photo-1742218409598-e3cd0aa02145',
      'names': 'Jojo Ituze'
    },
  ];
  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    double height = MediaQuery.sizeOf(context).height;
    return SizedBox(
      height: height * 0.9,
      child: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10, top: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: isLightTheme ? Colors.grey[100] : Colors.grey[900],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search for users...',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 1, horizontal: 15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(60)),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
            Expanded(
                child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {},
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                          users[index]['profile_picture_uri'].toString()),
                    ),
                    title: Text(users[index]['names'].toString()),
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
