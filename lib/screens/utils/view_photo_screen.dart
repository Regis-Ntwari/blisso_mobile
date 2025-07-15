import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/my_profile_service_provider.dart';
import 'package:blisso_mobile/utils/byte_image_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ViewPhotoScreen extends ConsumerStatefulWidget {
  final String imageURL;
  bool isBytes;
  final bool isMe;
  final bool isProfilePic;
  int id;
  ViewPhotoScreen(
      {super.key,
      required this.imageURL,
      this.isBytes = false,
      this.id = -1,
      required this.isMe,
      required this.isProfilePic});

  @override
  ConsumerState<ViewPhotoScreen> createState() => _ViewPhotoScreenState();
}

class _ViewPhotoScreenState extends ConsumerState<ViewPhotoScreen> {
  File? pickedImage;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    if (widget.isBytes) {}
    return SafeArea(
        child: Scaffold(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      appBar: AppBar(
        title: const Text('Image'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: isLightTheme ? Colors.black : Colors.white,
            )),
        backgroundColor: isLightTheme ? Colors.white : Colors.black,
        actions: [
          widget.isMe
              ? PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isLightTheme ? Colors.black : Colors.white,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      showModalBottomSheet(
                          constraints: const BoxConstraints(maxHeight: 200),
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (ctx) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                      onTap: () async {
                                        final picker = ImagePicker();
                                        final pickedFile =
                                            await picker.pickImage(
                                                source: ImageSource.camera);

                                        if (pickedFile != null) {
                                          setState(() {
                                            pickedImage = File(pickedFile.path);
                                            isLoading = true;
                                          });
                                          if (widget.isProfilePic) {
                                            Map<String, dynamic> newProfile = {
                                              ...ref
                                                  .read(
                                                      myProfileServiceProviderImpl)
                                                  .data,
                                              'profilePic': pickedImage!
                                            };

                                            await ref
                                                .read(
                                                    myProfileServiceProviderImpl
                                                        .notifier)
                                                .updateProfile(
                                                    TargetProfileModel
                                                        .fromMapNew(
                                                            newProfile));
                                          } else {
                                            await ref
                                                .read(
                                                    myProfileServiceProviderImpl
                                                        .notifier)
                                                .replaceImage(
                                                    pickedImage!, widget.id);
                                          }
                                          setState(() {
                                            isLoading = false;
                                          });
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: const Column(
                                        children: [
                                          CircleAvatar(
                                              backgroundColor: Colors.green,
                                              child: Icon(Icons.camera)),
                                          Text('Camera')
                                        ],
                                      )),
                                  InkWell(
                                      onTap: () async {
                                        final picker = ImagePicker();
                                        final pickedFile =
                                            await picker.pickImage(
                                                source: ImageSource.gallery);

                                        if (pickedFile != null) {
                                          setState(() {
                                            pickedImage = File(pickedFile.path);
                                            isLoading = true;
                                          });
                                          Navigator.of(context).pop();

                                          if (widget.isProfilePic) {
                                            Map<String, dynamic> newProfile = {
                                              ...ref
                                                  .read(
                                                      myProfileServiceProviderImpl)
                                                  .data,
                                              'profilePic': pickedImage
                                            };

                                            await ref
                                                .read(
                                                    myProfileServiceProviderImpl
                                                        .notifier)
                                                .updateProfile(
                                                    TargetProfileModel
                                                        .fromMapNew(
                                                            newProfile));
                                          } else {
                                            await ref
                                                .read(
                                                    myProfileServiceProviderImpl
                                                        .notifier)
                                                .replaceImage(
                                                    pickedImage!, widget.id);
                                          }

                                          setState(() {
                                            isLoading = false;
                                          });

                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: const Column(
                                        children: [
                                          CircleAvatar(
                                              backgroundColor: Colors.yellow,
                                              child: Icon(Icons.image)),
                                          Text('Gallery')
                                        ],
                                      ))
                                ],
                              ),
                            );
                          });
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit Photo'),
                      ),
                    ];
                  },
                )
              : const SizedBox.shrink()
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(
                color: GlobalColors.primaryColor,
              )
            : widget.isBytes
                ? Image.memory(Uint8List.fromList(
                    base64Decode(ref.read(byteImageProviderImpl))))
                : CachedNetworkImage(
                    imageUrl: widget.imageURL,
                    errorWidget: (context, url, error) => Icon(
                      Icons.no_photography,
                      color: isLightTheme ? Colors.black : Colors.white,
                    ),
                    placeholder: (context, url) => const Center(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: GlobalColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
      ),
    ));
  }
}
