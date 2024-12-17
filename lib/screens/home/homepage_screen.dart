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
  late final List<Widget> _widgetOptions = <Widget>[
    HomeComponent(
      profiles: null,
      refetch: refetchProfiles,
    ),
    SearchComponent(),
    ExploreComponent(),
    MyProfileComponent()
  ];

  int _selectedScreenIndex = 0;

  Future<void> getProfiles() async {
    final state = ref.read(profileServiceProviderImpl.notifier);

    await state.getAllProfiles();
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

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final profilesState = ref.watch(profileServiceProviderImpl);

    ref.listen(profileServiceProviderImpl, (previous, next) {
      if (next.data != null) {
        setState(() {
          _widgetOptions[0] = HomeComponent(
            profiles: next.data,
            refetch: refetchProfiles,
          );
        });
      }
    });

    return Scaffold(
      backgroundColor: isLightTheme ? GlobalColors.lightBackgroundColor : null,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              activeIcon:
                  const Icon(Icons.home, color: GlobalColors.primaryColor),
              icon: Icon(Icons.home, color: GlobalColors.secondaryColor),
              label: 'Home'),
          BottomNavigationBarItem(
              activeIcon:
                  const Icon(Icons.search, color: GlobalColors.primaryColor),
              icon: Icon(Icons.search, color: GlobalColors.secondaryColor),
              label: 'Search'),
          BottomNavigationBarItem(
              activeIcon:
                  const Icon(Icons.category, color: GlobalColors.primaryColor),
              icon: Icon(Icons.category, color: GlobalColors.secondaryColor),
              label: 'Explore'),
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
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: false,
                  floating: true,
                  snap: true,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        _selectedScreenIndex == 3 ? 'Profile' : 'Blisso',
                        style: TextStyle(
                          color: GlobalColors.primaryColor,
                          fontSize: scaler.scale(24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    centerTitle: false,
                  ),
                  actions: _selectedScreenIndex == 0
                      ? const [
                          Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.notifications),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.chat),
                          ),
                        ]
                      : [],
                ),
                SliverFillRemaining(
                  child: SafeArea(
                    child: _widgetOptions[_selectedScreenIndex],
                  ),
                ),
              ],
            ),
    );
  }
}
