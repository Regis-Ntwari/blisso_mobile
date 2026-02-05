import 'dart:io';

import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/screens/chat/attachments/video_post_modal.dart';
import 'package:blisso_mobile/screens/chat/chat_screen.dart';
import 'package:blisso_mobile/screens/explore/matching_recommendations.dart';
import 'package:blisso_mobile/screens/home/components/explore/explore_component.dart';
import 'package:blisso_mobile/screens/home/components/home_component.dart';
import 'package:blisso_mobile/services/chat/number_messages_provider.dart';
import 'package:blisso_mobile/services/matching/paginated_matching_service_provider.dart';
import 'package:blisso_mobile/services/permissions/permission_provider.dart';
import 'package:blisso_mobile/services/profile/first_profiles_provider.dart';
import 'package:blisso_mobile/services/profile/paginated_profiles_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/stories/paginated_video_post_provider.dart';
import 'package:blisso_mobile/services/stories/stories_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:routemaster/routemaster.dart';

class HomepageScreen extends ConsumerStatefulWidget {
  const HomepageScreen({super.key});

  @override
  ConsumerState<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends ConsumerState<HomepageScreen>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;
  int _selectedScreenIndex = 0;
  bool isSearchVisible = false;
  bool isProfileLoaded = false;
  String? firstname;
  String? lastname;
  String? profilePicture;

  String searchAttribute = 'Firstname';
  TextEditingController searchValue = TextEditingController();
  dynamic profiles;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!ref.read(firstProfileProviderImpl)) {
        await ref.read(paginatedProfilesProvider.notifier).loadFirstPage();
      }

      ref.read(firstProfileProviderImpl.notifier).updateProfile();

      if (ref.read(storiesServiceProviderImpl).data == null) {
        await ref.read(storiesServiceProviderImpl.notifier).getStories();
      }

      if (ref.read(paginatedVideoPostProvider).data.isEmpty) {
        await ref.read(paginatedVideoPostProvider.notifier).loadFirstPage();
      }
      if (ref.read(paginatedProfilesProvider).data.isEmpty) {
        await ref
            .read(paginatedMatchingServiceProvider.notifier)
            .loadFirstPage();
      }

      await ref
          .read(getNumberOfMessagesProvider.notifier)
          .getNumberOfMessages();

      await SharedPreferencesService.getPreference('firstname').then((value) {
        setState(() {
          firstname = value;
        });
      });

      await SharedPreferencesService.getPreference('lastname').then((value) {
        setState(() {
          lastname = value;
        });
      });

      await SharedPreferencesService.getPreference('profile_picture')
          .then((value) {
        setState(() {
          profilePicture = value;
        });
      });
    });
  }

  void _onScroll() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_selectedScreenIndex == 0) {
        await ref.read(paginatedProfilesProvider.notifier).loadNextPage();
      }
      if (_selectedScreenIndex == 1) {
        await ref
            .read(paginatedMatchingServiceProvider.notifier)
            .loadNextPage();
      }
      if (_selectedScreenIndex == 2) {
        await ref.read(paginatedVideoPostProvider.notifier).loadNextPage();
      }
    }
  }

  void _onSearchChange() {
    final state = ref.watch(paginatedProfilesProvider);
    final query = searchValue.text.trim().toLowerCase();
    // If the query is empty, reset profiles to the full dataset
    if (query.isEmpty) {
      setState(() {
        profiles = state.data;
      });
      return;
    }
    // Filter data
    final filteredData = state.data.where((profile) {
      final user = profile['user'] as Map<String, dynamic>? ?? {};
      switch (searchAttribute) {
        case 'Firstname':
          return user['first_name']?.toString().toLowerCase().contains(query) ??
              false;
        case 'Lastname':
          return user['last_name']?.toString().toLowerCase().contains(query) ??
              false;
        case 'Email':
          return user['email']?.toString().toLowerCase().contains(query) ??
              false;
        case 'Nickname':
          return profile['nickname']
                  ?.toString()
                  .toLowerCase()
                  .contains(query) ??
              false;
        case 'Home Address':
          return profile['home_address']
                  ?.toString()
                  .toLowerCase()
                  .contains(query) ??
              false;
        default:
          return false;
      }
    }).toList();
    setState(() {
      profiles = filteredData;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    super.build(context);

    final profilesState = ref.watch(paginatedProfilesProvider);
    final storiesState = ref.watch(storiesServiceProviderImpl);

    final Map<String, List<dynamic>> fetchedStories = {};

    if (!storiesState.isLoading && storiesState.data != null) {
      final myStories = storiesState.data['my_stories'];
      if (myStories['stories'].isNotEmpty) {
        fetchedStories[myStories['nickname']] = myStories['stories'];
      }
      for (var other in storiesState.data['others_stories']) {
        fetchedStories[other['nickname']] = other['stories'];
      }
    }

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isLightTheme
            ? (_selectedScreenIndex == 2 ? Colors.black : Colors.white)
            : Colors.black,
        automaticallyImplyLeading: false,
        title: _buildAppBarTitle(),
        actions: _buildAppBarActions(),
        bottom: isSearchVisible ? _buildSearchBar(isLightTheme) : null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(paginatedProfilesProvider.notifier).loadFirstPage();
            await ref.read(storiesServiceProviderImpl.notifier).getStories();
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              if (_selectedScreenIndex == 0) ...[
                SliverToBoxAdapter(
                  child: HomeComponent(
                    profiles: profilesState.data,
                    stories: fetchedStories,
                  ),
                ),
                if (profilesState.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: GlobalColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ] else if (_selectedScreenIndex == 1)
                MatchingRecommendations()
              else if (_selectedScreenIndex == 2)
                const SliverFillRemaining(
                  child: ExploreComponent(),
                )
              else
                const SliverFillRemaining(
                  child: ChatScreen(),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isLightTheme, context),
    );
  }

  BottomNavigationBar _buildBottomNav(bool isLightTheme, BuildContext context) {
    // Determine if we're on the Explore tab (index 2)
    final isExploreTab = _selectedScreenIndex == 2;

    // Determine colors based on current tab
    final backgroundColor = isLightTheme
        ? (isExploreTab ? Colors.black : Colors.white)
        : Colors.black;

    final unselectedColor =
        isExploreTab ? Colors.white : GlobalColors.secondaryColor;

    final selectedColor = GlobalColors.primaryColor;

    return BottomNavigationBar(
      backgroundColor: backgroundColor,
      currentIndex: _selectedScreenIndex,
      onTap: (index) {
        setState(() {
          _selectedScreenIndex = index;
        });
      },
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      type: BottomNavigationBarType.fixed, // Fixed prevents shifting
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compare),
          label: 'Match',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.chat),
              ref.watch(getNumberOfMessagesProvider)
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: GlobalColors.primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          label: 'Chat',
        ),
      ],
    );
  }

  Widget _buildAppBarTitle() {
    if (_selectedScreenIndex == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Blisso',
            style: TextStyle(
              fontSize: 24,
              color: GlobalColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Matching Recommendations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GlobalColors.primaryColor,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _selectedScreenIndex == 1 ? 'Matching Recommendations' : 'Blisso',
          style: TextStyle(
            color: GlobalColors.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_selectedScreenIndex == 0) {
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              isSearchVisible = !isSearchVisible;
            });
            if (!isSearchVisible) {
              searchValue.clear();
              _onSearchChange();
            }
          },
        ),
        _buildChatButtonWithBadge(),
      ];
    } else if (_selectedScreenIndex == 2) {
      return [
        IconButton(
          icon: const Row(
            children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 5),
              Text('New Post', style: TextStyle(color: Colors.white)),
            ],
          ),
          onPressed: () async {
            if (ref.read(permissionProviderImpl)['can_create_video_post']) {
              final picker = ImagePicker();
              final pickedFile = await picker.pickVideo(
                source: ImageSource.gallery,
              );
              if (pickedFile != null) {
                showVideoPostModal(context, File(pickedFile.path));
              }
            } else {
              showPopupComponent(
                context: context,
                icon: Icons.error,
                message: 'Please Upgrade your plan',
              );
            }
          },
        ),
      ];
    }
    return [];
  }

  Widget _buildChatButtonWithBadge() {
  return FutureBuilder<Map<String, String?>>(
    future: getInitials(),
    builder: (context, snapshot) {
      // Use local variables from snapshot or from state
      final profilePic = profilePicture ?? snapshot.data?['profile_picture'];
      final firstName = firstname ?? snapshot.data?['firstname'];
      final lastName = lastname ?? snapshot.data?['lastname'];

      if (profilePic != null && profilePic.isNotEmpty) {
        // Show circular profile picture
        return InkWell(
          onTap: () => Routemaster.of(context).push('/homepage/profile'),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(color: GlobalColors.primaryColor, width: 2.0),
              borderRadius: BorderRadius.circular(15), // Half of 30 for perfect circle
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15), // Half of 30 for perfect circle
              child: CachedNetworkImage(
                imageUrl: profilePic,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircleAvatar(
                  radius: 15,
                  backgroundColor: GlobalColors.primaryColor.withOpacity(0.3),
                  child: Text(
                    '${firstName?.isNotEmpty == true ? firstName![0] : 'U'}'
                    '${lastName?.isNotEmpty == true ? lastName![0] : 'U'}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  radius: 15,
                  backgroundColor: GlobalColors.primaryColor,
                  child: Text(
                    '${firstName?.isNotEmpty == true ? firstName![0] : 'U'}'
                    '${lastName?.isNotEmpty == true ? lastName![0] : 'U'}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        // Show initials as fallback
        return InkWell(
          onTap: () => Routemaster.of(context).push('/homepage/profile'),
          child: CircleAvatar(
            radius: 15,
            backgroundColor: GlobalColors.primaryColor,
            child: Text(
              '${firstName?.isNotEmpty == true ? firstName![0] : 'U'}'
              '${lastName?.isNotEmpty == true ? lastName![0] : 'U'}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    },
  );
}

  //

  Future<Map<String, String?>> getInitials() async {
    String? profilePicture =
        await SharedPreferencesService.getPreference('profile_picture');
    String? firstname =
        await SharedPreferencesService.getPreference('firstname');
    String? lastname = await SharedPreferencesService.getPreference('lastname');

    return {
      'profile_picture': profilePicture,
      'firstname': firstname,
      'lastname': lastname
    };
  }

  PreferredSizeWidget _buildSearchBar(bool isLightTheme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 35,
              decoration: BoxDecoration(
                color: isLightTheme
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFF111112),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isLightTheme ? Colors.grey[300]! : Colors.grey[700]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Dropdown
                  Container(
                    height: 35,
                    constraints: const BoxConstraints(
                      minWidth: 60,
                      maxWidth: 120,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: searchAttribute,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 8,
                        borderRadius: BorderRadius.circular(25),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        isDense: true,
                        isExpanded: true,
                        dropdownColor:
                            isLightTheme ? Colors.white : Colors.grey[900],
                        style: TextStyle(
                          color: isLightTheme ? Colors.black87 : Colors.white,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                        items: <String>[
                          'Firstname',
                          'Lastname',
                          'Email',
                          'Nickname',
                          'Home Address'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: isLightTheme
                                    ? Colors.grey[500]
                                    : Colors.white,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            searchAttribute = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  // Search Field
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: Center(
                        child: TextField(
                          maxLines: 1,
                          controller: searchValue,
                          onChanged: (value) => _onSearchChange(),
                          style: TextStyle(
                            color: isLightTheme ? Colors.black87 : Colors.white,
                            fontSize: 14,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                            hintText: 'Search by $searchAttribute...',
                            hintStyle: TextStyle(
                              color: isLightTheme
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            border: InputBorder.none,
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.search,
                                color: isLightTheme
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                                size: 20,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Close Button
                  Container(
                    height: 35,
                    width: 40,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.close,
                        color:
                            isLightTheme ? Colors.grey[600] : Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          isSearchVisible = false;
                          searchValue.clear();
                          _onSearchChange();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
