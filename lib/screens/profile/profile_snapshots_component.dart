import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:blisso_mobile/utils/global_fonts.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class ProfileSnapshotsComponent extends StatefulWidget {
  final List<int> chosenValues;
  final Function checkInterest;
  final Function toggleInterest;
  const ProfileSnapshotsComponent(
      {super.key,
      required this.chosenValues,
      required this.checkInterest,
      required this.toggleInterest});

  @override
  State<ProfileSnapshotsComponent> createState() =>
      _ProfileSnapshotsComponentState();
}

class _ProfileSnapshotsComponentState extends State<ProfileSnapshotsComponent> {
  int detailsIndex = 0;

  final List<String> _chosenValues = [];

  late List<Map<String, List<String>>> _filteredValues;

  var details = [
    {
      'Interests': [
        'Reading',
        'Swimming',
        'Hockey',
        'Football',
        'Basketball',
        'Adventure',
      ],
    },
    {
      'Hobbies': [
        'Play',
        'Pray',
        'Fly',
      ]
    }
  ];

  Future<void> fetchProfileSnapshots() async {}

  @override
  void initState() {
    super.initState();
    _copyList();
  }

  void _copyList() {
    setState(() {
      _filteredValues = details
          .map((element) => Map<String, List<String>>.from(element))
          .toList();
    });
  }

  bool checkIfSelected(element) {
    return _chosenValues.contains(element);
  }

  void addItemToChosen(element) {
    if (!_chosenValues.contains(element)) {
      setState(() {
        _chosenValues.add(element);
      });
    } else {
      setState(() {
        _chosenValues.remove(element);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final key = _filteredValues[detailsIndex].keys.first;
    final values = _filteredValues[detailsIndex][key];
    return SizedBox(
      height: 500,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
              child: Text(
                'Choose your attributes',
                style: TextStyle(
                    fontSize: scaler.scale(GlobalFonts.title),
                    color: GlobalColors.primaryColor),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: values!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () => addItemToChosen(values[index]),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  border: Border.all(
                                      color: checkIfSelected(values[index])
                                          ? GlobalColors.primaryColor
                                          : Colors.transparent)),
                              child: Card(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    values[index],
                                  ),
                                ),
                              ),
                            ),
                            checkIfSelected(values[index])
                                ? const Positioned(
                                    child: Icon(
                                      Icons.verified,
                                      color: GlobalColors.primaryColor,
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
