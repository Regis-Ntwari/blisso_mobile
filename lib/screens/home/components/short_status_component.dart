import 'dart:convert';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class ShortStatusComponent extends ConsumerStatefulWidget {
  final Map<String, List<dynamic>> statuses; // Updated to Map

  const ShortStatusComponent({super.key, required this.statuses});

  @override
  ConsumerState<ShortStatusComponent> createState() =>
      _ShortStatusComponentState();
}

class _ShortStatusComponentState extends ConsumerState<ShortStatusComponent> {
  String? profilePicture;
  bool isLoading = true;

  Future<void> getProfilePicture() async {
    String picture =
        await SharedPreferencesService.getPreference('profile_picture');

    setState(() {
      profilePicture = picture;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getProfilePicture();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> usernames = widget.statuses.keys.toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: usernames.length + 1, // +1 to include "Add Story" button
        itemBuilder: (context, index) {
          if (index == 0) {
            // Add Story Button
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      // Navigate to Add Story Page
                      // Navigator.pushNamed(context, '/add_story');
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            !isLoading && profilePicture != null
                                ? CachedNetworkImage(
                                    imageUrl: profilePicture!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(
                                      color: GlobalColors.primaryColor,
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                        Icons.person,
                                        size: 50,
                                        color: GlobalColors.whiteColor),
                                  )
                                : const CircularProgressIndicator(
                                    color: GlobalColors.primaryColor,
                                  ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Align(
                              alignment: Alignment.center,
                              child: Icon(Icons.add,
                                  color: Colors.white, size: 30),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "My Story",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Display Other Users' Stories
            final String username = usernames[index - 1]; // Adjust index
            final List<dynamic> userStatuses = widget.statuses[username]!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      // Encode list of statuses for the selected user
                      String encodedData = jsonEncode(userStatuses);
                      Routemaster.of(context)
                          .push('/homepage/view-story?data=$encodedData');
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
                        child: CachedNetworkImage(
                          imageUrl: userStatuses[0]['profile'], // User Profile
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(
                            color: GlobalColors.primaryColor,
                          ),
                          errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              size: 50,
                              color: GlobalColors.whiteColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    username.length > 10
                        ? '${username.substring(0, 10).trim()}...'
                        : username,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
