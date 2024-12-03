import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/auth/profile/snapshots/profile_snapshots_component.dart';
import 'package:blisso_mobile/services/snapshots/my_snapshots_provider.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class SnapshotScreen extends ConsumerStatefulWidget {
  const SnapshotScreen({super.key});

  @override
  ConsumerState<SnapshotScreen> createState() => _SnapshotScreenState();
}

class _SnapshotScreenState extends ConsumerState<SnapshotScreen> {
  final List<int> _chosenOwnInterests = [];

  bool isLoading = true;

  Future<void> fetchProfileSnapshots() async {
    final state = ref.read(snapshotServiceProviderImpl.notifier);

    await state.getLifeSnapshots();
  }

  void addOwnInterest(interest) {
    if (_chosenOwnInterests.contains(interest['id'])) {
      setState(() {
        _chosenOwnInterests.remove(interest['id']);
      });
    } else {
      _chosenOwnInterests.add(interest['id']);
    }
  }

  bool checkInterest(interest) {
    return _chosenOwnInterests.contains(interest['id']);
  }

  List<Map<String, List<Map<String, dynamic>>>> buildList(List<dynamic> data) {
    List<Map<String, List<Map<String, dynamic>>>> groupedData = [];

    for (var item in data) {
      String subCategory = item['sub_category'];

      var existingEntry = groupedData.firstWhere(
        (element) => element.containsKey(subCategory),
        orElse: () => {},
      );

      if (existingEntry.isNotEmpty) {
        existingEntry[subCategory]!.add(item);
      } else {
        groupedData.add({
          subCategory: [item]
        });
      }
    }
    return groupedData;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProfileSnapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(snapshotServiceProviderImpl);
    final chosenValues = ref.watch(mySnapshotsProviderImpl);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return (state.isLoading && isLoading) || state.data == null
        ? const LoadingScreen()
        : SafeArea(
            child: Scaffold(
              backgroundColor:
                  isLightTheme ? GlobalColors.lightBackgroundColor : null,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                    onPressed: () {
                      Routemaster.of(context).pop();
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_left,
                      color: GlobalColors.secondaryColor,
                    )),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      ProfileSnapshotsComponent(
                          values:
                              state.data != null ? buildList(state.data!) : [],
                          chosenValues: chosenValues,
                          checkInterest: ref
                              .read(mySnapshotsProviderImpl.notifier)
                              .containsInterest,
                          toggleInterest: ref
                              .read(mySnapshotsProviderImpl.notifier)
                              .toggleInterest)
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
