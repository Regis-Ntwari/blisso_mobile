// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:blisso_mobile/components/popup_component.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';

class ImageComponent extends StatefulWidget {
  final Function changeProfilePicture;
  final Function onContinue;
  final File? profilePicture;
  const ImageComponent(
      {super.key,
      required this.profilePicture,
      required this.changeProfilePicture,
      required this.onContinue});

  @override
  State<ImageComponent> createState() => _ImageComponentState();
}

class _ImageComponentState extends State<ImageComponent> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, int flag) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      widget.changeProfilePicture(File(pickedFile.path));
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
    double height = MediaQuery.sizeOf(context).height;
    TextScaler textScaler = MediaQuery.textScalerOf(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                'Profile Image',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: textScaler.scale(24),
                    color: GlobalColors.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Choose your profile picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: textScaler.scale(12)),
                ),
              ),
              InkWell(
                onTap: () => _showImagePickerOptions(0),
                child: CircleAvatar(
                    radius: height * 0.15,
                    backgroundColor: Colors.grey[500],
                    backgroundImage: widget.profilePicture != null
                        ? FileImage(widget.profilePicture!)
                        : null,
                    child: const Align(
                      alignment: Alignment.center,
                      child:
                          Icon(Icons.camera_alt, size: 50, color: Colors.white),
                    )),
              )
            ]),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ButtonComponent(
                  text: 'Next',
                  backgroundColor: GlobalColors.primaryColor,
                  foregroundColor: GlobalColors.whiteColor,
                  onTap: () {
                    if (widget.profilePicture == null) {
                      showPopupComponent(
                          context: context,
                          icon: Icons.dangerous,
                          message: 'Please choose your profile');
                    } else {
                      widget.onContinue();
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
