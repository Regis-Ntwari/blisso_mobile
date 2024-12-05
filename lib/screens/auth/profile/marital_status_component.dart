import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/pill_button_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class MaritalStatusComponent extends StatelessWidget {
  final List<String> statuses;
  final String chosenStatus;
  final Function changeStatus;
  final Function onContinue;
  const MaritalStatusComponent(
      {super.key,
      required this.statuses,
      required this.chosenStatus,
      required this.changeStatus,
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
              'Marital Status ',
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
                      text: statuses[index],
                      buttonColor: chosenStatus == statuses[index]
                          ? GlobalColors.primaryColor
                          : GlobalColors.whiteColor,
                      foregroundColor: chosenStatus == statuses[index]
                          ? GlobalColors.whiteColor
                          : GlobalColors.primaryColor,
                      onPressed: () => changeStatus(statuses[index])),
                );
              },
              itemCount: statuses.length,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
            ),
          ),
          ButtonComponent(
              text: 'Save Profile',
              backgroundColor: GlobalColors.primaryColor,
              foregroundColor: GlobalColors.whiteColor,
              onTap: () {
                if (chosenStatus == '') {
                  showPopupComponent(
                      context: context,
                      icon: Icons.dangerous,
                      message: 'Please, choose your marital status');
                } else {
                  onContinue();
                }
              })
        ],
      ),
    );
  }
}
