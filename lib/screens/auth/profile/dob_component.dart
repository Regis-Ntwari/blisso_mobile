import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';

class DobComponent extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController dayController;
  final TextEditingController monthController;
  final TextEditingController yearController;

  final FocusNode dayFocusNode;
  final FocusNode monthFocusNode;
  final FocusNode yearFocusNode;

  final VoidCallback onTap;

  const DobComponent(
      {super.key,
      required this.formKey,
      required this.dayController,
      required this.monthController,
      required this.yearController,
      required this.dayFocusNode,
      required this.monthFocusNode,
      required this.yearFocusNode,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 20),
              child: Text(
                AppLocalizations.of(context)!.dateOfBirthTitle,
                style: TextStyle(
                    fontSize: scaler.scale(32),
                    color: GlobalColors.primaryColor),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Day input
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    controller: dayController,
                    focusNode: dayFocusNode,
                    maxLength: 2,
                    decoration: const InputDecoration(
                      labelText: 'DD',
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.dayValidator1;
                      }
                      final day = int.tryParse(value);
                      if (day == null || day < 1 || day > 31) {
                        return AppLocalizations.of(context)!.dayValidator2;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.length == 2) {
                        FocusScope.of(context).requestFocus(monthFocusNode);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Month input
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    controller: monthController,
                    focusNode: monthFocusNode,
                    maxLength: 2,
                    decoration: const InputDecoration(
                      labelText: 'MM',
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.monthValidator1;
                      }
                      final month = int.tryParse(value);
                      if (month == null || month < 1 || month > 12) {
                        return AppLocalizations.of(context)!.monthValidator2;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.length == 2) {
                        FocusScope.of(context).requestFocus(yearFocusNode);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Year input
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: yearController,
                    focusNode: yearFocusNode,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'YYYY',
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.yearValidator1;
                      }
                      final year = int.tryParse(value);
                      if (year == null ||
                          year < 1900 ||
                          year > DateTime.now().year) {
                        return AppLocalizations.of(context)!.yearValidator2;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.length == 4) {
                        FocusScope.of(context)
                            .unfocus(); // Move out of the field after year input
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ButtonComponent(
                text: AppLocalizations.of(context)!.continuei,
                backgroundColor: GlobalColors.primaryColor,
                foregroundColor: GlobalColors.whiteColor,
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    onTap();
                  }
                })
          ],
        ),
      ),
    );
  }
}
