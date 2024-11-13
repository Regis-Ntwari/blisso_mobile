import 'dart:io';

import 'package:blisso_mobile/screens/profile/dob_component.dart';
import 'package:blisso_mobile/screens/profile/gender_component.dart';
import 'package:blisso_mobile/screens/profile/image_component.dart';
import 'package:blisso_mobile/screens/profile/location_component.dart';
import 'package:blisso_mobile/screens/profile/nickname_component.dart';
import 'package:blisso_mobile/screens/profile/profile_snapshots_component.dart';
import 'package:blisso_mobile/screens/profile/sexual_orientation_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  final List<String> genders = ['MALE', 'FEMALE'];
  final List<String> sexes = ['MALE', 'FEMALE'];

  late Position position;

  late String address;

  File? _profilePicture;

  File? _firstPicture;
  File? _secondPicture;
  File? _thirdPicture;
  File? _fourthPicture;

  final List<int> _chosenOwnInterests = [];

  @override
  void initState() {
    super.initState();
  }

  void changePosition(Position position) {
    setState(() {
      this.position = position;
    });
  }

  void changeAddress(String address) {
    setState(() {
      this.address = address;
    });
  }

  void changeProfilePicture(File? file) {
    setState(() {
      _profilePicture = file;
    });
  }

  void changeFirstPicture(File? file) {
    setState(() {
      _firstPicture = file;
    });
  }

  void changeSecondPicture(File? file) {
    setState(() {
      _secondPicture = file;
    });
  }

  void changeThirdPicture(File? file) {
    setState(() {
      _thirdPicture = file;
    });
  }

  void changeFourthPicture(File? file) {
    setState(() {
      _fourthPicture = file;
    });
  }

  void addOwnInterest(interest) {
    if (_chosenOwnInterests.contains(interest['id'])) {
      setState(() {
        _chosenOwnInterests.remove(interest['id']);
      });
    } else {
      _chosenOwnInterests.add(interest['id']);
    }
  }

  bool checkInterest(interest) {
    return _chosenOwnInterests.contains(interest['id']);
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
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10),
                child: Column(
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
                          onContinue: () {
                            setState(() {
                              _index = _index + 1;
                            });
                          },
                          changeSex: (sex) {
                            setState(() {
                              chosenSex = sex;
                            });
                          })
                    else if (_index == 5)
                      LocationComponent(
                        onChangeAddress: changeAddress,
                        onChangePosition: changePosition,
                        onContinue: () {
                          setState(() {
                            _index = _index + 1;
                          });
                        },
                      )
                    else if (_index == 6)
                      ImageComponent(
                        changeFirstPicture: changeFirstPicture,
                        changeFourthPicture: changeFourthPicture,
                        changeProfilePicture: changeProfilePicture,
                        changeSecondPicture: changeSecondPicture,
                        changeThirdPicture: changeThirdPicture,
                        onContinue: () {
                          setState(() {
                            _index = _index + 1;
                          });
                        },
                      )
                    else if (_index == 7)
                      ProfileSnapshotsComponent(
                        checkInterest: checkInterest,
                        chosenValues: _chosenOwnInterests,
                        toggleInterest: addOwnInterest,
                      )
                  ],
                ),
              ),
            )));
  }
}
