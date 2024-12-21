import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/home/components/explore/explore_component.dart';
import 'package:blisso_mobile/screens/home/components/home_component.dart';
import 'package:blisso_mobile/screens/home/components/search/search_component.dart';
import 'package:blisso_mobile/screens/home/components/profile/my_profile_component.dart';
import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomepageScreen extends ConsumerStatefulWidget {
  const HomepageScreen({super.key});

  @override
  ConsumerState<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends ConsumerState<HomepageScreen> {
  bool isSearchVisible = false;

  int _selectedScreenIndex = 0;

  String searchAttribute = 'Firstname';

  TextEditingController searchValue = TextEditingController();

  dynamic profiles;

  Future<void> getProfiles() async {
    final state = ref.read(profileServiceProviderImpl.notifier);

    await state.getAllProfiles();

    final profilesState = ref.watch(profileServiceProviderImpl);

    setState(() {
      profiles = profilesState.data;
    });
  }

  Future<void> refetchProfiles() async {
    getProfiles();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getProfiles();
    });
  }

  void _onScreenChanged(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  void _onSearchChange() {
    final state = ref.watch(profileServiceProviderImpl);
    final filteredData = state.data.where((profile) {
      final filteredUser = profile['user'];
      return filteredUser['first_name']
              .toLowerCase()
              .contains(searchValue.text.toLowerCase()) ||
          filteredUser['last_name']
              .toLowerCase()
              .contains(searchValue.text.toLowerCase()) ||
          filteredUser['email']
              .toLowerCase()
              .contains(searchValue.text.toLowerCase());
    }).toList();

    print("== $filteredData");

    setState(() {
      profiles = filteredData;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final profilesState = ref.watch(profileServiceProviderImpl);

    final List<Widget> widgetOptions = <Widget>[
      HomeComponent(
        profiles: profiles,
        refetch: refetchProfiles,
      ),
      SearchComponent(),
      ExploreComponent(),
      MyProfileComponent()
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
      backgroundColor: isLightTheme ? GlobalColors.lightBackgroundColor : null,
      bottomNavigationBar: BottomNavigationBar(
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
      body: profilesState.isLoading || profilesState.data == null
          ? const LoadingScreen()
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    elevation: 5,
                    floating: true,
                    snap: true,
                    expandedHeight: isSearchVisible ? 140 : 70, // Adjust height
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
                                        onPressed: () {},
                                      ),
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isSearchVisible)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: searchValue,
                                      onChanged: (value) => _onSearchChange(),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Search by Firstname, Lastname or Email...',
                                        border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: GlobalColors.primaryColor),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        isSearchVisible = false;
                                        searchValue.clear();
                                        _onSearchChange();
                                      });
                                    },
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
