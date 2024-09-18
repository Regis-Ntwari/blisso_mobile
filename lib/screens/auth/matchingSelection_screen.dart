import 'package:blisso_mobile/components/button_component.dart';
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

  Map<String, double> _chosenValues = {};

  void _showScalePopup(BuildContext context, String attribute) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            child: StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text('Choose Scale for $attribute'),
                content: Slider(
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
                      setState(() {
                        _chosenValues[attribute] = value;
                      });
                    }),
                actions: [
                  TextButton(
                      onPressed: () {
                        Routemaster.of(context).pop();
                      },
                      child: const Text('OK'))
                ],
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
        'Adventure'
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
  Widget build(BuildContext context) {
    final key = details[detailsIndex].keys.first;
    final values = details[detailsIndex][key];
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                    child: Text(
                      key,
                      style: const TextStyle(color: Colors.red, fontSize: 32),
                    ),
                  ),
                  GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _calculateCrossAxisCount(context),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1),
                      itemCount: values!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () => _showScalePopup(context, values[index]),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Wrap(
                                children: [Text(values[index])],
                              ),
                            ),
                          ),
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ButtonComponent(
                          text: 'Back',
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          onTap: () {
                            if (detailsIndex != 0) {
                              setState(() {
                                detailsIndex = detailsIndex - 1;
                              });
                            }
                          },
                        ),
                        ButtonComponent(
                          text: 'Next',
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          onTap: () {
                            if (detailsIndex != details.length - 1) {
                              setState(() {
                                detailsIndex = detailsIndex + 1;
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ButtonComponent(
                        text: 'Back to Register',
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        onTap: () {
                          Routemaster.of(context).replace('/register');
                        }),
                  )
                ],
              )),
        ),
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
