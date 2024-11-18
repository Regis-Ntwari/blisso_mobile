import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class NicknameComponent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final VoidCallback onContinue;

  const NicknameComponent(
      {super.key,
      required this.formKey,
      required this.onContinue,
      required this.controller});

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
            AppLocalizations.of(context)!.nicknameTitle,
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
                      controller: controller,
                      decoration: InputDecoration(
                          labelText:
                              '${AppLocalizations.of(context)!.nickname} *',
                          hintText: AppLocalizations.of(context)!.hintNickname),
                      validator: (value) {
                        if (value == null) {
                          return AppLocalizations.of(context)!
                              .validatorNickname1;
                        }
                        if (value.trim().length < 3) {
                          return AppLocalizations.of(context)!
                              .validatorNickname2;
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
                  AppLocalizations.of(context)!.nicknameSubtitle,
                  style: TextStyle(
                      fontSize: scaler.scale(9),
                      color: GlobalColors.secondaryColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ButtonComponent(
                    text: AppLocalizations.of(context)!.continuei,
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
