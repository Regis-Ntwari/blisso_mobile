import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class NicknameComponent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onContinue;

  const NicknameComponent(
      {super.key, required this.formKey, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 10,
            right: 10,
          ),
          child: Text(
            'My Nickname is',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: scaler.scale(32),
            ),
          ),
        ),
        SizedBox(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Nickname *',
                          hintText: 'Enter your Nickname'),
                      validator: (value) {
                        if (value == null) {
                          return 'Your nickname should be present';
                        }
                        if (value.trim().length < 3) {
                          return 'Your nickname requires a minimum of 3 characters';
                        }
                        return null;
                      },
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: Text(
                  'Nickname should be chosen once. You will not be able to change it afterwards',
                  style: TextStyle(
                      fontSize: scaler.scale(9),
                      color: GlobalColors.secondaryColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ButtonComponent(
                    text: 'Continue',
                    backgroundColor: GlobalColors.primaryColor,
                    foregroundColor: GlobalColors.whiteColor,
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        onContinue();
                      }
                    }),
              )
            ],
          ),
        ),
      ],
    );
  }
}
