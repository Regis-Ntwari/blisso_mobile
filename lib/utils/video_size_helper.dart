import 'dart:io';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

const int maxChatVideoSizeMB = 20;
const int maxVideoPostSizeMB = 20;
const int maxStoryVideoSizeMB = 20;
const int maxFileSizeMB = 20;

double getFileSizeMB(File file) {
  final bytes = file.lengthSync();
  return bytes / (1024 * 1024);
}

bool isVideoWithinSizeLimit(File file, int maxSizeMB) {
  return getFileSizeMB(file) <= maxSizeMB;
}

bool isFileWithinSizeLimit(File file, int maxSizeMB) {
  return getFileSizeMB(file) <= maxSizeMB;
}

void showVideoTooLargeError(BuildContext context, double sizeMB, int maxMB) {
  showFileTooLargeError(context, sizeMB, maxMB);
}

void showFileTooLargeError(BuildContext context, double sizeMB, int maxMB) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'File is too large (${sizeMB.toStringAsFixed(1)}MB). Maximum allowed size is ${maxMB}MB.',
      ),
      backgroundColor: GlobalColors.primaryColor,
      duration: const Duration(seconds: 3),
    ),
  );
}
