import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/pill_button_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class SexualOrientationComponent extends StatelessWidget {
  final List<String> sexes;
  final String chosenSex;
  final Function changeSex;
  final VoidCallback onContinue;
  const SexualOrientationComponent(
      {super.key,
      required this.sexes,
      required this.chosenSex,
      required this.changeSex,
      required this.onContinue});

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    double height = MediaQuery.sizeOf(context).height;
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(children: [
            Text(
              'Who are you interested in ',
              style: TextStyle(
                  fontSize: scaler.scale(32), color: GlobalColors.primaryColor),
            ),
          ]),
          SizedBox(
            height: height * 0.5,
            child: ListView.builder(
              itemBuilder: (ctx, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: PillButtonComponent(
                      text: sexes[index],
                      buttonColor: chosenSex == sexes[index]
                          ? GlobalColors.primaryColor
                          : GlobalColors.whiteColor,
                      foregroundColor: chosenSex == sexes[index]
                          ? GlobalColors.whiteColor
                          : GlobalColors.primaryColor,
                      onPressed: () => changeSex(sexes[index])),
                );
              },
              itemCount: sexes.length,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
            ),
          ),
          ButtonComponent(
              text: 'Continue',
              backgroundColor: GlobalColors.primaryColor,
              foregroundColor: GlobalColors.whiteColor,
              onTap: onContinue)
        ],
      ),
    );
  }
}
