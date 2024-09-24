import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class MatchingSelectionScreen extends StatefulWidget {
  const MatchingSelectionScreen({super.key});

  @override
  State<MatchingSelectionScreen> createState() =>
      _MatchingSelectionScreenState();
}

class _MatchingSelectionScreenState extends State<MatchingSelectionScreen> {
  int detailsIndex = 0;

  final Map<String, double> _chosenValues = {};

  late List<Map<String, List<String>>> _filteredValues;

  TextEditingController _searchController = TextEditingController();

  void _showScalePopup(BuildContext context, String attribute) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            child: StatefulBuilder(builder: (context, setStateDialog) {
              return SizedBox(
                height: 300,
                child: AlertDialog(
                  title: Text('Choose Scale for $attribute'),
                  content: Slider(
                      activeColor: Colors.red,
                      value: _chosenValues[attribute] == null
                          ? 0
                          : _chosenValues[attribute]!,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: _chosenValues[attribute] == null
                          ? '0.0'
                          : _chosenValues[attribute]!.toStringAsFixed(1),
                      onChanged: (value) {
                        setStateDialog(() {
                          _chosenValues[attribute] = value;
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

  void _onSearchChange(index, key) {
    String searchText = _searchController.text;

    setState(() {
      _filteredValues[index][key] = details[index][key]!
          .where((element) =>
              element.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = _filteredValues[detailsIndex].keys.first;
    final values = _filteredValues[detailsIndex][key];
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: const Text(
              'Blisso',
              style: TextStyle(color: Colors.red, fontSize: 18),
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
                    onChanged: (value) => _onSearchChange(detailsIndex, key),
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
                      padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              if (detailsIndex != 0) {
                                setState(() {
                                  detailsIndex = detailsIndex - 1;
                                  _searchController = TextEditingController();
                                });
                                _copyList();
                              }
                            },
                            child: Icon(
                              Icons.keyboard_arrow_left,
                              size: 30,
                              color: detailsIndex == 0
                                  ? Colors.grey[700]
                                  : Colors.red,
                            ),
                          ),
                          Text(
                            key,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 32),
                          ),
                          InkWell(
                            onTap: () {
                              if (detailsIndex != details.length - 1) {
                                setState(() {
                                  detailsIndex = detailsIndex + 1;
                                  _searchController = TextEditingController();
                                });
                                _copyList();
                              }
                            },
                            child: Icon(
                              Icons.keyboard_arrow_right,
                              size: 30,
                              color: (detailsIndex == details.length - 1)
                                  ? Colors.grey[700]
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 10),
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
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () =>
                                    _showScalePopup(context, values[index]),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Wrap(
                                          children: [Text(values[index])],
                                        ),
                                        Text(
                                          '${_chosenValues[values[index]] == null ? 0 : _chosenValues[values[index]]!.toStringAsFixed(1)}/10',
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
          ]))
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
