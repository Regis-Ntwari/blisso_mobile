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
  final List<Widget> _widgetOptions = <Widget>[
    HomeComponent(profiles: null),
    SearchComponent(),
    ExploreComponent(),
    MyProfileComponent()
  ];

  int _selectedScreenIndex = 0;

  Future<void> getProfiles() async {
    final state = ref.read(profileServiceProviderImpl.notifier);

    await state.getAllProfiles();
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
          _widgetOptions[0] = HomeComponent(profiles: next.data);
        });
      }
    });
    return Scaffold(
      backgroundColor: isLightTheme ? GlobalColors.lightBackgroundColor : null,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              activeIcon: const Icon(
                Icons.home,
                color: GlobalColors.primaryColor,
              ),
              icon: Icon(
                Icons.home,
                color: GlobalColors.secondaryColor,
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              activeIcon: const Icon(
                Icons.search,
                color: GlobalColors.primaryColor,
              ),
              icon: Icon(
                Icons.search,
                color: GlobalColors.secondaryColor,
              ),
              label: 'Search'),
          BottomNavigationBarItem(
              activeIcon: const Icon(
                Icons.category,
                color: GlobalColors.primaryColor,
              ),
              icon: Icon(
                Icons.category,
                color: GlobalColors.secondaryColor,
              ),
              label: 'Explore'),
          BottomNavigationBarItem(
            activeIcon: const Icon(
              Icons.person,
              color: GlobalColors.primaryColor,
            ),
            icon: Icon(
              Icons.person,
              color: GlobalColors.secondaryColor,
            ),
            label: 'Profile',
          )
        ],
        onTap: (value) => _onScreenChanged(value),
        currentIndex: _selectedScreenIndex,
        selectedItemColor: GlobalColors.primaryColor,
        selectedLabelStyle: const TextStyle(color: GlobalColors.primaryColor),
        selectedIconTheme:
            const IconThemeData(color: GlobalColors.primaryColor),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Blisso',
          style: TextStyle(
              color: GlobalColors.primaryColor, fontSize: scaler.scale(24)),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications),
          ),
          Padding(
              padding: EdgeInsets.only(right: 20, left: 20),
              child: Icon(Icons.chat)),
        ],
      ),
      body: profilesState.isLoading || profilesState.data == null
          ? const LoadingScreen()
          : SafeArea(
              child: _widgetOptions[_selectedScreenIndex],
            ),
    );
  }
}
