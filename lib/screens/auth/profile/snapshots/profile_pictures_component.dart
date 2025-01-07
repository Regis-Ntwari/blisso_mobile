import 'dart:io';

import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:routemaster/routemaster.dart';

class ProfilePicturesComponent extends ConsumerStatefulWidget {
  const ProfilePicturesComponent({
    super.key,
  });

  @override
  ConsumerState<ProfilePicturesComponent> createState() =>
      _ProfilePicturesComponentState();
}

class _ProfilePicturesComponentState
    extends ConsumerState<ProfilePicturesComponent> {
  File? _firstPicture;
  File? _secondPicture;
  File? _thirdPicture;
  File? _fourthPicture;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, int flag) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (flag == 1) {
          _firstPicture = File(pickedFile.path);
        } else if (flag == 2) {
          _secondPicture = File(pickedFile.path);
        } else if (flag == 3) {
          _thirdPicture = File(pickedFile.path);
        } else if (flag == 4) {
          _fourthPicture = File(pickedFile.path);
        }
      });
    }
  }

  void _showImagePickerOptions(int flag) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery, flag);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera, flag);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.of(context).textScaler;
    double height = MediaQuery.sizeOf(context).height;
    final snapshot = ref.watch(snapshotServiceProviderImpl);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Blisso',
          style: TextStyle(
              color: GlobalColors.primaryColor, fontSize: scaler.scale(24)),
        ),
      ),
      backgroundColor: isLightTheme ? GlobalColors.lightBackgroundColor : null,
      body: snapshot.isLoading
          ? const LoadingScreen()
          : SingleChildScrollView(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Choose 4 pictures of your choice',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: scaler.scale(24),
                        color: GlobalColors.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Column(children: [
                    SizedBox(
                      height: height * 0.5,
                      child: GridView.count(
                        crossAxisCount: 2,
                        children: [
                          InkWell(
                              onTap: () => _showImagePickerOptions(1),
                              child: SizedBox(
                                height: 50,
                                child: Card(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _firstPicture != null
                                          ? Image(
                                              image: FileImage(_firstPicture!),
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.camera_alt,
                                              size: 50,
                                            ),
                                      Container(
                                        color: Colors.black.withOpacity(0.3),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                          InkWell(
                              onTap: () => _showImagePickerOptions(2),
                              child: SizedBox(
                                height: 50,
                                child: Card(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _secondPicture != null
                                          ? Image(
                                              image: FileImage(_secondPicture!),
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.camera_alt,
                                              size: 50,
                                            ),
                                      Container(
                                        color: Colors.black.withOpacity(0.3),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                          InkWell(
                              onTap: () => _showImagePickerOptions(3),
                              child: SizedBox(
                                height: 50,
                                child: Card(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _thirdPicture != null
                                          ? Image(
                                              image: FileImage(_thirdPicture!),
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.camera_alt,
                                              size: 50,
                                            ),
                                      Container(
                                        color: Colors.black.withOpacity(0.3),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                          InkWell(
                              onTap: () => _showImagePickerOptions(4),
                              child: SizedBox(
                                height: 50,
                                child: Card(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _fourthPicture != null
                                          ? Image(
                                              image: FileImage(_fourthPicture!),
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.camera_alt,
                                              size: 50,
                                            ),
                                      Container(
                                        color: Colors.black.withOpacity(0.3),
                                      )
                                    ],
                                  ),
                                ),
                              ))
                        ],
                      ),
                    )
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ButtonComponent(
                      text: 'Submit',
                      backgroundColor: GlobalColors.primaryColor,
                      foregroundColor: GlobalColors.whiteColor,
                      onTap: () async {
                        if (_firstPicture == null ||
                            _secondPicture == null ||
                            _thirdPicture == null ||
                            _fourthPicture == null) {
                          showPopupComponent(
                              context: context,
                              icon: Icons.dangerous,
                              message:
                                  'Please ensure you have added all photos');
                        } else {
                          await ref
                              .read(snapshotServiceProviderImpl.notifier)
                              .postProfileImages([
                            _firstPicture!,
                            _secondPicture!,
                            _thirdPicture!,
                            _fourthPicture!
                          ]);

                          final snapshot =
                              ref.read(snapshotServiceProviderImpl);
                          if (snapshot.error != null) {
                            showSnackBar(context, snapshot.error!);
                          } else {
                            Routemaster.of(context).push('/subscription');
                          }
                        }
                      }),
                )
              ],
            )),
    ));
  }
}
