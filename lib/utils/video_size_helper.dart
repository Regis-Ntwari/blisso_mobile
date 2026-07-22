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
  // Get the screen height to calculate the margin offset
  final double screenHeight = MediaQuery.of(context).size.height;
  // Get top padding (safe area like notch or status bar)
  final double topPadding = MediaQuery.of(context).padding.top;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      // Allow the user to swipe it up to dismiss
      dismissDirection: DismissDirection.up,
      // Push the snackbar to the top by adding a large bottom margin
      margin: EdgeInsets.only(
        bottom: screenHeight - topPadding - 100, // Adjust the 100 based on your AppBar height
        left: 20,
        right: 20,
      ),
      content: Text(
        'File is too large (${sizeMB.toStringAsFixed(1)}MB). Maximum allowed size is ${maxMB}MB.',
      ),
      backgroundColor: GlobalColors.primaryColor,
      duration: const Duration(seconds: 3),
    ),
  );
}