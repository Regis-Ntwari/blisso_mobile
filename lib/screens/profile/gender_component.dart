import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/pill_button_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class GenderComponent extends StatelessWidget {
  final List<String> genders;
  final String chosenGender;
  final Function changeGender;
  final VoidCallback onContinue;
  const GenderComponent(
      {super.key,
      required this.genders,
      required this.chosenGender,
      required this.changeGender,
      required this.onContinue});

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    double height = MediaQuery.sizeOf(context).height;
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Text(
            'Choose your Gender ',
            style: TextStyle(
                fontSize: scaler.scale(32), color: GlobalColors.primaryColor),
          ),
          SizedBox(
            height: height * 0.5,
            child: ListView.builder(
              itemBuilder: (ctx, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: PillButtonComponent(
                      text: genders[index],
                      buttonColor: chosenGender == genders[index]
                          ? GlobalColors.primaryColor
                          : GlobalColors.whiteColor,
                      foregroundColor: chosenGender == genders[index]
                          ? GlobalColors.whiteColor
                          : GlobalColors.primaryColor,
                      onPressed: () => changeGender(genders[index])),
                );
              },
              itemCount: genders.length,
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
