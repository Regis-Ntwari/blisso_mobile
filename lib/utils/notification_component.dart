import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationComponent {
  static void showInAppNotification({
    required String title,
    required String message,
    required String avatarUrl,
    required VoidCallback onTap,
  }) {
    showOverlayNotification(
      (context) {
        return _InAppNotification(
          title: title,
          message: message,
          avatarUrl: avatarUrl,
          onTap: () {
            onTap();
            OverlaySupportEntry.of(context)!.dismiss();
          },
          onDismiss: () => OverlaySupportEntry.of(context)!.dismiss(),
        );
      },
      duration: const Duration(seconds: 5),
      position: NotificationPosition.top,
    );
  }
}

class _InAppNotification extends StatelessWidget {
  final String title;
  final String message;
  final String avatarUrl;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotification({
    required this.title,
    required this.message,
    required this.avatarUrl,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: isLightTheme ? Colors.white : Colors.black,
          elevation: 8.0,
          borderRadius: BorderRadius.circular(12.0),
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: isLightTheme ?Colors.grey.shade200 : Colors.black),
              ),
              child: Row(
                children: [
                  // Avatar
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onDismiss,
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}