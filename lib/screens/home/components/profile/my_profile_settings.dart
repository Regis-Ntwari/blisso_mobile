import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/my_profile_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MyProfileSettings extends ConsumerStatefulWidget {
  const MyProfileSettings({super.key});

  @override
  ConsumerState<MyProfileSettings> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<MyProfileSettings> {
  // Initial/default values (could be fetched from your state)
  String? gender = 'male';
  String? maritalStatus = 'single';
  String? showMe = 'men';
  DateTime? dob = DateTime(2022, 1, 1);
  String? distanceMeasure = 'Km';
  String? homeAddress = '';
  bool isLoading = false;

  // Sample dropdown values
  final List<String> genderOptions = ['male', 'female'];
  final List<String> maritalStatusOptions = [
    'single',
    'married',
    'divorced',
    'widowed'
  ];
  final List<String> showMeOptions = ['men', 'women', 'everyone'];
  final List<String> distanceOptions = ['Miles', 'Km'];

  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(myProfileServiceProviderImpl).data;

      setState(() {
        gender = profile['gender'];
        maritalStatus = profile['marital_status'];
        showMe = profile['show_me'];
        dob = DateTime.parse(profile['dob']);
        distanceMeasure = profile['distance_measure'];
        addressController.text = profile['home_address'];
      });
    });
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dob,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dob = picked;
      });
    }
  }

  void _saveChanges() async{
    setState(() {
      isLoading = true;
    });
    final profileService = ref.read(myProfileServiceProviderImpl);
    final existingData = profileService.data;

    // Merge updated fields with existing profile data
    Map<String, dynamic> updatedData = {
      ...existingData, // keep all existing keys
      'gender': gender,
      'marital_status': maritalStatus,
      'show_me': showMe,
      'dob': dob?.toIso8601String().split('T')[0],
      'distance_measure': distanceMeasure,
      'home_address': addressController.text,
    };

    final myProfile = ref.read(myProfileServiceProviderImpl.notifier);

    await myProfile.updateProfile(TargetProfileModel.fromMapNewNoProfile(updatedData));

    setState(() {
      isLoading = false;
    });

    Navigator.of(context).pop();
  }

  Widget _buildDropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return Center(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            DropdownButton<String>(
              isExpanded: true,
              value: value,
              onChanged: onChanged,
              items: options.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.keyboard_arrow_left)),
          title: const Text('Edit Profile Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildDropdown('Gender', gender!, genderOptions,
                (val) => setState(() => gender = val!)),
            const SizedBox(height: 16),
            _buildDropdown(
                'Marital Status',
                maritalStatus!,
                maritalStatusOptions,
                (val) => setState(() => maritalStatus = val!)),
            const SizedBox(height: 16),
            _buildDropdown('Show Me', showMe!, showMeOptions,
                (val) => setState(() => showMe = val!)),
            const SizedBox(height: 16),
            Center(
              child: ListTile(
                title: const Text('Date of Birth'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(dob!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
                'Distance Measure',
                distanceMeasure!,
                distanceOptions,
                (val) => setState(() => distanceMeasure = val!)),
            const SizedBox(height: 16),
            Center(
              child: TextInputComponent(
                controller: addressController,
                labelText: 'Home address',
                hintText: 'Enter Home address',
                validatorFunction: () {},
              ),
            ),
            const SizedBox(height: 24),
            Center(
                child: isLoading ? const CircularProgressIndicator(color: GlobalColors.primaryColor,) : ButtonComponent(
                    text: 'Save Changes',
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    onTap: _saveChanges))
          ],
        ),
      ),
    );
  }
}
