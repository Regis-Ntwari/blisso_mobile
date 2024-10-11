import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                  onPressed: () {
                    Routemaster.of(context).pop();
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    color: GlobalColors.secondaryColor,
                  )),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'My Nickname is',
                    style: TextStyle(fontSize: scaler.scale(32)),
                  ),
                ),
                SizedBox(
                  child: Column(
                    children: [
                      TextFormField(
                        key: _formKey,
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
                            onTap: () {}),
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}
