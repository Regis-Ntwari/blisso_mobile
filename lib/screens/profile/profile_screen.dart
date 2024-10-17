import 'package:blisso_mobile/screens/profile/dob_component.dart';
import 'package:blisso_mobile/screens/profile/gender_component.dart';
import 'package:blisso_mobile/screens/profile/nickname_component.dart';
import 'package:blisso_mobile/screens/profile/sexual_orientation_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nicknameFormKey = GlobalKey<FormState>();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String chosenGender = '';
  String chosenSex = '';

  final FocusNode _dayFocusNode = FocusNode();
  final FocusNode _monthFocusNode = FocusNode();
  final FocusNode _yearFocusNode = FocusNode();

  late Map<int, Widget> profile;

  int _index = 1;

  final List<String> genders = ['MALE', 'FEMALE', 'NON BINARY'];
  final List<String> sexes = ['MALE', 'FEMALE', 'GAY'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _dayFocusNode.dispose();
    _monthFocusNode.dispose();
    _yearFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_index == 1)
                  NicknameComponent(
                    formKey: _nicknameFormKey,
                    onContinue: () => setState(() {
                      _index = _index + 1;
                    }),
                  )
                else if (_index == 2)
                  DobComponent(
                    dayController: _dayController,
                    dayFocusNode: _dayFocusNode,
                    monthController: _monthController,
                    monthFocusNode: _monthFocusNode,
                    yearController: _yearController,
                    yearFocusNode: _yearFocusNode,
                    formKey: _formKey,
                    onTap: () => setState(() {
                      _index = _index + 1;
                    }),
                  )
                else if (_index == 3)
                  GenderComponent(
                      key: ValueKey(chosenGender),
                      genders: genders,
                      chosenGender: chosenGender,
                      changeGender: (gender) {
                        setState(() {
                          chosenGender = gender;
                        });
                      },
                      onContinue: () {
                        setState(() {
                          _index = _index + 1;
                        });
                      })
                else if (_index == 4)
                  SexualOrientationComponent(
                      sexes: sexes,
                      chosenSex: chosenSex,
                      changeSex: (sex) {
                        setState(() {
                          chosenSex = sex;
                        });
                      })
              ],
            )));
  }
}
