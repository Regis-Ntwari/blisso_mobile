import 'dart:io';

import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ViewPictureComponent extends StatefulWidget {
  final Map<String, dynamic> image;
  final bool isEdit;
  final Function? savePicture;
  final File? chosenPicture;
  final Function? updateChosenPicture;
  const ViewPictureComponent(
      {super.key,
      required this.image,
      required this.isEdit,
      this.savePicture,
      this.chosenPicture,
      this.updateChosenPicture});

  @override
  State<ViewPictureComponent> createState() => _ViewPictureComponentState();
}

class _ViewPictureComponentState extends State<ViewPictureComponent> {
  final ImagePicker _picker = ImagePicker();

  File? _chosenPicture;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      widget.updateChosenPicture!(File(pickedFile.path));
      setState(() {
        _chosenPicture = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
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
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
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
    double width = MediaQuery.sizeOf(context).width;
    return Dialog(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRect(
            child: SizedBox(
              width: width * 0.95,
              height: width * 0.95,
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 3.0,
                child: _chosenPicture == null
                    ? CachedNetworkImage(
                        imageUrl: widget.image['image_uri'],
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        _chosenPicture!,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
          if (widget.isEdit)
            Positioned(
              bottom: 20,
              right: 20,
              child: InkWell(
                onTap: () {
                  _chosenPicture == null
                      ? _showImagePickerOptions()
                      : widget.savePicture!(widget.image);
                },
                child: Container(
                  decoration:
                      const BoxDecoration(color: GlobalColors.primaryColor),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      _chosenPicture == null ? Icons.edit : Icons.save,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void showPictureDialog(
    {required BuildContext context,
    required Map<String, dynamic> image,
    bool isEdit = false,
    Function? savePicture,
    File? chosenPicture,
    Function? updatePicture}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return ViewPictureComponent(
            image: image,
            isEdit: isEdit,
            savePicture: (Map<String, dynamic> image) {
              savePicture!(image);
            },
            chosenPicture: chosenPicture,
            updateChosenPicture: (File file) {
              updatePicture!(file);
              setState(() {});
            },
          );
        },
      );
    },
  );
}
