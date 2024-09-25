import 'package:flutter/material.dart';

class TextInputComponent extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final Function validatorFunction;
  const TextInputComponent(
      {super.key,
      required this.controller,
      required this.labelText,
      required this.hintText,
      required this.validatorFunction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 6, right: 6),
      child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[800],
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
              labelText: labelText),
          validator: (value) => validatorFunction(value)),
    );
  }
}
