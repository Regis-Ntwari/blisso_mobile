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
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Wrap(
                              children: [Text(values[index])],
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
                            Routemaster.of(context).pop();
                          },
                        ),
                        ButtonComponent(
                          text: 'Next',
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          onTap: () {
                            setState(() {
                              detailsIndex = detailsIndex + 1;
                            });
                          },
                        )
                      ],
                    ),
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
