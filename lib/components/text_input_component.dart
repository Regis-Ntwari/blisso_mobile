import 'package:flutter/material.dart';

class TextInputComponent extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final Function validatorFunction;
  final TextInputType? keyboardType;
  const TextInputComponent(
      {super.key,
      required this.controller,
      required this.labelText,
      required this.hintText,
      required this.validatorFunction,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    final bool isThemeBright = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding:
          const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 6, right: 6),
      child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
              filled: true,
              fillColor: isThemeBright ? Colors.grey[50] : Colors.grey[800],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              border: InputBorder.none,
              enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(color: Colors.transparent)),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              hintText: hintText,
              labelText: labelText,
              floatingLabelBehavior: FloatingLabelBehavior.auto),
          validator: (value) => validatorFunction(value)),
    );
  }
}
