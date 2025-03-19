import 'package:blisso_mobile/components/view_picture_status_component.dart';
import 'package:flutter/material.dart';
import 'package:blisso_mobile/utils/global_colors.dart';

class ShortStatusComponent extends StatelessWidget {
  final List<dynamic> statuses;

  const ShortStatusComponent({super.key, required this.statuses});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    showPictureStatusDialog(
                        context: context, image: status['imageUrl']);
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: GlobalColors.primaryColor, width: 3),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        status['profile'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 50,
                            color: GlobalColors.whiteColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  children: [
                    Text(
                      status['username'].toString().length > 10
                          ? '${status['username'].toString().substring(0, 10)}...'
                          : status['username'],
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
