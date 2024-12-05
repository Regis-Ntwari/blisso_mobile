import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class TargetProfileSnapshotsComponent extends ConsumerStatefulWidget {
  const TargetProfileSnapshotsComponent({super.key});

  @override
  ConsumerState<TargetProfileSnapshotsComponent> createState() =>
      _TargetProfileSnapshotsComponentState();
}

class _TargetProfileSnapshotsComponentState
    extends ConsumerState<TargetProfileSnapshotsComponent> {
  int detailsIndex = 0;

  final List<Map<String, dynamic>> _chosenValues = [{}];

  late List<Map<String, List<Map<String, dynamic>>>> _filteredValues = [];

  late List<Map<String, List<Map<String, dynamic>>>> _originalList;

  TextEditingController _searchController = TextEditingController();

  bool isLoading = true;

  void _showScalePopup(BuildContext context, Map<String, dynamic> attribute) {
    int index =
        _chosenValues.indexWhere((element) => element['id'] == attribute['id']);
    if (index == -1) {
      _chosenValues.add({'id': attribute['id'], 'scale': 0});
      index = _chosenValues.length - 1;
    }
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            child: StatefulBuilder(builder: (context, setStateDialog) {
              return SizedBox(
                height: 300,
                child: AlertDialog(
                  title: Text('Choose Scale for ${attribute["name"]}'),
                  content: Slider(
                      activeColor: Colors.red,
                      value: _chosenValues[index]['scale'].toDouble(),
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: _chosenValues[index]['scale'].toString(),
                      onChanged: (value) {
                        setStateDialog(() {
                          _chosenValues[index]['scale'] = value;
                        });
                        setState(
                          () {},
                        );
                      }),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Routemaster.of(context).pop();
                        },
                        child: const Text('OK'))
                  ],
                ),
              );
            }),
          );
        });
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

  Future<void> fetchProfileSnapshots() async {
    final state = ref.read(snapshotServiceProviderImpl.notifier);

    await state.getLifeSnapshots();

    final response = ref.watch(snapshotServiceProviderImpl);

    setState(() {
      _originalList = buildList(response.data);
    });
    _copyList(_originalList);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProfileSnapshots();
    });
  }

  void _copyList(List<Map<String, List<Map<String, dynamic>>>> list) {
    setState(() {
      _filteredValues = list
          .map((element) =>
              Map<String, List<Map<String, dynamic>>>.from(element))
          .toList();
    });
  }

  void _onSearchChange(index, key) {
    String searchText = _searchController.text;

    setState(() {
      _filteredValues[index][key] = _originalList[index][key]!
          .where((element) =>
              element['name'].toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  dynamic getScaleAttribute(Map<String, dynamic> attribute) {
    for (var at in _chosenValues) {
      if (at['id'] == attribute['id']) {
        return at['scale'];
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_filteredValues.isEmpty) {
      return const LoadingScreen();
    }
    final key = _filteredValues[detailsIndex].keys.elementAt(0);
    final values = _filteredValues[detailsIndex][key];
    var snapshot = ref.watch(snapshotServiceProviderImpl);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            isLightTheme ? GlobalColors.lightBackgroundColor : null,
        body: snapshot.isLoading
            ? const LoadingScreen()
            : CustomScrollView(slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  snap: false,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  title: const Text(
                    'Blisso',
                    style: TextStyle(
                        color: GlobalColors.primaryColor, fontSize: 18),
                  ),
                  bottom: AppBar(
                    automaticallyImplyLeading: false,
                    title: Container(
                      width: double.infinity,
                      height: 40,
                      color: Colors.white,
                      child: Center(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              _onSearchChange(detailsIndex, key),
                          decoration: InputDecoration(
                              hintText: 'Search for $key',
                              prefixIcon: const Icon(Icons.search)),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                    delegate: SliverChildListDelegate([
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (detailsIndex != 0) {
                                      setState(() {
                                        detailsIndex = detailsIndex - 1;
                                        _searchController =
                                            TextEditingController();
                                      });
                                      _copyList(_originalList);
                                    }
                                  },
                                  child: Icon(
                                    Icons.keyboard_arrow_left,
                                    size: 30,
                                    color: detailsIndex == 0
                                        ? GlobalColors.secondaryColor
                                        : GlobalColors.primaryColor,
                                  ),
                                ),
                                Text(
                                  key,
                                  style: const TextStyle(
                                      color: GlobalColors.primaryColor,
                                      fontSize: 32),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (detailsIndex !=
                                        _originalList.length - 1) {
                                      setState(() {
                                        detailsIndex = detailsIndex + 1;
                                        _searchController =
                                            TextEditingController();
                                      });
                                      _copyList(_originalList);
                                    }
                                  },
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 30,
                                    color: (detailsIndex ==
                                            _originalList.length - 1)
                                        ? GlobalColors.secondaryColor
                                        : GlobalColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 10),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Click the $key which you want and choose a scale out of 10',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          values!.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Center(
                                    child: Text(
                                      'No search record found',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              _calculateCrossAxisCount(context),
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 1),
                                  itemCount: values.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                      onTap: () => _showScalePopup(
                                          context, values[index]),
                                      child: Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Wrap(
                                                children: [
                                                  Text(values[index]['name'])
                                                ],
                                              ),
                                              Text(
                                                "${getScaleAttribute(values[index])}",
                                                style: const TextStyle(
                                                    color: Colors.grey),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                        ],
                      )),
                ])),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ButtonComponent(
                        text: 'Submit',
                        backgroundColor: GlobalColors.primaryColor,
                        foregroundColor: GlobalColors.whiteColor,
                        onTap: () async {
                          bool isListEffectivelyEmpty = _chosenValues.isEmpty ||
                              _chosenValues.every((map) => map.isEmpty);

                          if (isListEffectivelyEmpty) {
                            showPopupComponent(
                                context: context,
                                icon: Icons.dangerous,
                                message:
                                    'Please choose atleast one target interest');
                          } else {
                            await ref
                                .read(snapshotServiceProviderImpl.notifier)
                                .postTargetProfileSnapshots(_chosenValues);

                            snapshot = ref.read(snapshotServiceProviderImpl);
                            if (snapshot.error != null) {
                              showSnackBar(context, snapshot.error!);
                            } else {
                              Routemaster.of(context).push(
                                  "/auto-write/Now, let's add gorgeous pictures/profile-pictures");
                            }
                          }
                        }),
                  ),
                )
              ]),
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;

    if (screenWidth >= 1000) {
      return 6;
    } else if (screenWidth >= 700) {
      return 4;
    } else {
      return 3;
    }
  }
}
