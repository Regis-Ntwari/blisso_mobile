import 'package:blisso_mobile/components/button_loading_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/my_profile_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditMyProfileComponent extends ConsumerStatefulWidget {
  final TargetProfileModel targetProfileModel;
  const EditMyProfileComponent({super.key, required this.targetProfileModel});

  @override
  ConsumerState<EditMyProfileComponent> createState() =>
      _EditMyProfileComponentState();
}

class _EditMyProfileComponentState
    extends ConsumerState<EditMyProfileComponent> {
  final TextEditingController nicknameController = TextEditingController();

  final TextEditingController dobController = TextEditingController();

  final TextEditingController homeAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    nicknameController.text = widget.targetProfileModel.nickname!;

    homeAddressController.text = widget.targetProfileModel.homeAddress!;

    dobController.text = widget.targetProfileModel.dob!;
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(myProfileServiceProviderImpl);
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      child: SingleChildScrollView(
        child: Form(
            child: Column(
          children: [
            TextInputComponent(
                controller: nicknameController,
                labelText: 'Nickname',
                hintText: 'Enter your Nickname',
                validatorFunction: () {}),
            TextInputComponent(
                controller: dobController,
                labelText: 'Date of Birth',
                hintText: 'Enter your Date of Birth',
                validatorFunction: () {}),
            TextInputComponent(
                controller: homeAddressController,
                labelText: 'Home Address',
                hintText: 'Enter your Home address',
                validatorFunction: () {}),
            ButtonLoadingComponent(
                widget: profileState.isLoading
                    ? CircularProgressIndicator(
                        color: isLightTheme ? Colors.white : Colors.black,
                      )
                    : Text(
                        'Update',
                        style: TextStyle(
                            color: isLightTheme ? Colors.white : Colors.black),
                      ),
                backgroundColor: GlobalColors.lightBackgroundColor,
                foregroundColor: GlobalColors.lightBackgroundColor,
                onTap: () async {
                  widget.targetProfileModel.nickname = nicknameController.text;
                  widget.targetProfileModel.dob = dobController.text;
                  widget.targetProfileModel.homeAddress =
                      homeAddressController.text;

                  final profileRef =
                      ref.read(myProfileServiceProviderImpl.notifier);
                  await profileRef.updateProfile(widget.targetProfileModel);

                  Navigator.of(context).pop();
                })
          ],
        )),
      ),
    );
  }
}

void showEditMyProfileComponent(
    {required BuildContext context,
    required TargetProfileModel targetProfileModel}) {
  showDialog(
    context: context,
    builder: (context) {
      return EditMyProfileComponent(targetProfileModel: targetProfileModel);
    },
  );
}
