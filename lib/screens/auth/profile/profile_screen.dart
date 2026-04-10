import 'dart:io';

import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/screens/auth/profile/dob_component.dart';
import 'package:blisso_mobile/screens/auth/profile/gender_component.dart';
import 'package:blisso_mobile/screens/auth/profile/image_component.dart';
import 'package:blisso_mobile/screens/auth/profile/location_component.dart';
import 'package:blisso_mobile/screens/auth/profile/marital_status_component.dart';
import 'package:blisso_mobile/screens/auth/profile/nickname_component.dart';
import 'package:blisso_mobile/screens/auth/profile/relationship_goal_component.dart';
import 'package:blisso_mobile/screens/auth/profile/sexual_orientation_component.dart';
import 'package:blisso_mobile/services/location/location_service_provider.dart';
import 'package:blisso_mobile/services/models/profile_model.dart';
import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:routemaster/routemaster.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nicknameFormKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Location fields
  final _residenceCountryController = TextEditingController();
  final _residenceCityController = TextEditingController();
  final _nationalityController = TextEditingController();

  String chosenGender = '';
  String chosenSex = '';
  String chosenStatus = '';
  String chosenGoal = '';

  final FocusNode _dayFocusNode = FocusNode();
  final FocusNode _monthFocusNode = FocusNode();
  final FocusNode _yearFocusNode = FocusNode();

  int _index = 1;

  final List<String> genders = ['MALE', 'FEMALE'];
  final List<String> statuses = ['SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED'];
  final List<String> sexes = ['MEN', 'WOMEN', 'EVERYONE'];

  Position? position;
  String? address;
  File? _profilePicture;

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

  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  void saveProfile(BuildContext context) async {
    final profile = ProfileModel(
      nickname: _nicknameController.text,
      dob:
          '${_yearController.text}-${_monthController.text}-${_dayController.text}',
      latitude: position!.latitude.toString(),
      longitude: position!.longitude.toString(),
      profilePic: _profilePicture!,
      gender: chosenGender.toLowerCase(),
      showMe: chosenSex.toLowerCase(),
      residenceCountry: _residenceCountryController.text,
      residenceCity: _residenceCityController.text,
      nationality: _nationalityController.text,
      lookingFor: chosenGoal.toLowerCase(),
      maritalStatus: chosenStatus.toLowerCase(),
      lang: capitalize('ENGLISH'),
    );

    await ref.read(profileServiceProviderImpl.notifier).createProfile(profile);

    final userState = ref.read(profileServiceProviderImpl);
    if (userState.error != null) {
      showSnackBar(context, userState.error!);
    } else {
      Routemaster.of(context).push(
          "/auto-write/Profile done!! Let's choose our interests/snapshots");
    }
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _dayFocusNode.dispose();
    _monthFocusNode.dispose();
    _yearFocusNode.dispose();
    _nicknameController.dispose();
    _residenceCountryController.dispose();
    _residenceCityController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(profileServiceProviderImpl);
    final locationState = ref.watch(locationServiceProviderImpl);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor:
          isLightTheme ? GlobalColors.lightBackgroundColor : Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _index > 1
            ? IconButton(
                onPressed: () => setState(() => _index = _index - 1),
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  color: GlobalColors.secondaryColor,
                  size: 28,
                ))
            : IconButton(
                onPressed: () => null,
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  color: GlobalColors.secondaryColor,
                  size: 28,
                )),
      ),
      body: userState.isLoading || locationState.isLoading
          ? const LoadingScreen()
          : SafeArea(
            child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_index == 1)
                        NicknameComponent(
                          formKey: _nicknameFormKey,
                          controller: _nicknameController,
                          onContinue: () => setState(() => _index = _index + 1),
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
                          onTap: () => setState(() => _index = _index + 1),
                        )
                      else if (_index == 3)
                        GenderComponent(
                          key: ValueKey(chosenGender),
                          genders: genders,
                          chosenGender: chosenGender,
                          changeGender: (gender) {
                            setState(() => chosenGender = gender);
                          },
                          onContinue: () => setState(() => _index = _index + 1),
                        )
                      else if (_index == 4)
                        SexualOrientationComponent(
                          sexes: sexes,
                          chosenSex: chosenSex,
                          onContinue: () => setState(() => _index = _index + 1),
                          changeSex: (sex) => setState(() => chosenSex = sex),
                        )
                      else if (_index == 5)
                        LocationComponent(
                          onChangeAddress: changeAddress,
                          onChangePosition: changePosition,
                          location: position,
                          homeAddress:
                              _residenceCityController, // kept for compat
                          residenceCountryController:
                              _residenceCountryController,
                          residenceCityController: _residenceCityController,
                          nationalityController: _nationalityController,
                          onContinue: () => setState(() => _index = _index + 1),
                        )
                      else if (_index == 6)
                        ImageComponent(
                          changeProfilePicture: changeProfilePicture,
                          profilePicture: _profilePicture,
                          onContinue: () => setState(() => _index = _index + 1),
                        )
                      else if (_index == 7)
                        MaritalStatusComponent(
                          statuses: statuses,
                          chosenStatus: chosenStatus,
                          changeStatus: (status) =>
                              setState(() => chosenStatus = status),
                          onContinue: () =>
                              setState(() => _index = 8), // Now goes to step 8
                        )
                      else if (_index == 8)
                        RelationshipGoalComponent(
                          chosenGoal: chosenGoal,
                          changeGoal: (goal) =>
                              setState(() => chosenGoal = goal),
                          onContinue: () =>
                              saveProfile(context), // Final submission
                        )
                    ],
                  ),
                ),
              ),
          ),
    );
  }
}
