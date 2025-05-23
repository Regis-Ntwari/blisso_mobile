import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/home/components/explore/explore_component.dart';
import 'package:blisso_mobile/screens/home/components/home_component.dart';
import 'package:blisso_mobile/screens/home/components/search/search_component.dart';
import 'package:blisso_mobile/screens/home/components/profile/my_profile_component.dart';
import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/services/websocket/websocket_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomepageScreen extends ConsumerStatefulWidget {
  const HomepageScreen({super.key});

  @override
  ConsumerState<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends ConsumerState<HomepageScreen>
    with AutomaticKeepAliveClientMixin {
  bool isSearchVisible = false;

  int _selectedScreenIndex = 0;

  String searchAttribute = 'Firstname';

  TextEditingController searchValue = TextEditingController();

  dynamic profiles;

  @override
  bool get wantKeepAlive => true;

  Future<void> getProfiles() async {
    final state = ref.read(profileServiceProviderImpl.notifier);

    if (ref.read(profileServiceProviderImpl).data == null) {
      await state.getAllProfiles();
    }

    final profilesState = ref.read(profileServiceProviderImpl);

    setState(() {
      profiles = profilesState.data;
    });
  }

  Future<void> initializeSocket() async {
    final webSocketState = ref.read(webSocketNotifierProvider.notifier);

    await webSocketState.connect();

    webSocketState.listenToMessages();
  }

  Future<void> refetchProfiles() async {
    getProfiles();
  }

  @override
  void initState() {
    super.initState();
    initializeSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (profiles == null) {
        getProfiles();
      }
    });
  }

  void _onScreenChanged(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  void _onSearchChange() {
    final state = ref.watch(profileServiceProviderImpl);
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
  Widget build(BuildContext context) {
    super.build(context);
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final profilesState = ref.watch(profileServiceProviderImpl);

    final List<Widget> widgetOptions = <Widget>[
      HomeComponent(
        profiles: profiles,
        refetch: refetchProfiles,
      ),
      const SearchComponent(),
      const ExploreComponent(),
      const MyProfileComponent()
    ];

    // ref.listen(profileServiceProviderImpl, (previous, next) {
    //   if (next.data != null) {
    //     setState(() {
    //       profiles = next.data;
    //       _widgetOptions[0] = HomeComponent(
    //         profiles: profiles,
    //         refetch: refetchProfiles,
    //       );
    //     });
    //   }
    // });

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isLightTheme ? Colors.white : Colors.black,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            activeIcon:
                const Icon(Icons.home, color: GlobalColors.primaryColor),
            icon: Icon(Icons.home, color: GlobalColors.secondaryColor),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            activeIcon:
                const Icon(Icons.search, color: GlobalColors.primaryColor),
            icon: Icon(Icons.search, color: GlobalColors.secondaryColor),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            activeIcon:
                const Icon(Icons.category, color: GlobalColors.primaryColor),
            icon: Icon(Icons.category, color: GlobalColors.secondaryColor),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            activeIcon:
                const Icon(Icons.person, color: GlobalColors.primaryColor),
            icon: Icon(Icons.person, color: GlobalColors.secondaryColor),
            label: 'Profile',
          ),
        ],
        onTap: (value) => _onScreenChanged(value),
        currentIndex: _selectedScreenIndex,
        selectedItemColor: GlobalColors.primaryColor,
        selectedLabelStyle: const TextStyle(color: GlobalColors.primaryColor),
        selectedIconTheme:
            const IconThemeData(color: GlobalColors.primaryColor),
      ),
      body: profilesState.isLoading
          ? const LoadingScreen()
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    elevation: 5,
                    floating: true,
                    backgroundColor: isLightTheme ? Colors.white : Colors.black,
                    snap: true,
                    expandedHeight: isSearchVisible ? 120 : 60,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedScreenIndex == 3
                                      ? 'Profile'
                                      : 'Blisso',
                                  style: TextStyle(
                                    color: GlobalColors.primaryColor,
                                    fontSize: scaler.scale(24),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (_selectedScreenIndex == 0) ...[
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
                                      IconButton(
                                        icon: const Icon(Icons.notifications),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.chat),
                                        onPressed: () {
                                          Routemaster.of(context).push('/chat');
                                        },
                                      ),
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isSearchVisible)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                children: [
                                  Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: isLightTheme
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: isLightTheme
                                            ? Colors.grey[300]!
                                            : Colors.grey[700]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Dropdown
                                        Container(
                                          height: 45,
                                          constraints: const BoxConstraints(
                                              minWidth: 100, maxWidth: 150),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: isLightTheme
                                                    ? Colors.grey[300]!
                                                    : Colors.grey[700]!,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: searchAttribute,
                                              icon: const Icon(
                                                  Icons.arrow_drop_down),
                                              elevation: 8,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              isDense: true,
                                              isExpanded:
                                                  true, // Makes dropdown text responsive
                                              dropdownColor: isLightTheme
                                                  ? Colors.white
                                                  : Colors.grey[900],
                                              style: TextStyle(
                                                color: isLightTheme
                                                    ? Colors.black87
                                                    : Colors.white,
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
                                                          ? Colors.black87
                                                          : Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                          child: Container(
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              height: 70,
                                              alignment: Alignment.center,
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: TextField(
                                                  maxLines: 1,
                                                  controller: searchValue,
                                                  onChanged: (value) =>
                                                      _onSearchChange(),
                                                  style: TextStyle(
                                                    color: isLightTheme
                                                        ? Colors.black87
                                                        : Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    hintText:
                                                        'Search by $searchAttribute...',
                                                    hintStyle: TextStyle(
                                                      color: isLightTheme
                                                          ? Colors.grey[600]
                                                          : Colors.grey[400],
                                                      fontSize: 14,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    border: InputBorder.none,
                                                    prefixIcon: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      child: Icon(
                                                        Icons.search,
                                                        color: isLightTheme
                                                            ? Colors.grey[600]
                                                            : Colors.grey[400],
                                                        size: 20,
                                                      ),
                                                    ),
                                                    prefixIconConstraints:
                                                        const BoxConstraints(
                                                      minWidth: 40,
                                                      minHeight: 40,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                        ),
                                        // Close Button
                                        Container(
                                          height: 45,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: isLightTheme
                                                    ? Colors.grey[300]!
                                                    : Colors.grey[700]!,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints:
                                                const BoxConstraints(), // Removes default padding
                                            icon: Icon(
                                              Icons.close,
                                              color: isLightTheme
                                                  ? Colors.grey[600]
                                                  : Colors.grey[400],
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
                                  if (searchValue.text.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isLightTheme
                                            ? Colors.grey[100]
                                            : Colors.grey[900],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isLightTheme
                                              ? Colors.grey[300]!
                                              : Colors.grey[700]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Searching by: $searchAttribute',
                                        style: TextStyle(
                                          color: isLightTheme
                                              ? Colors.grey[600]
                                              : Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    child: widgetOptions[_selectedScreenIndex],
                  ),
                ],
              ),
            ),
    );
  }
}
