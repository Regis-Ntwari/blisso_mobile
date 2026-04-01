import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/my_profile_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:blisso_mobile/utils/relationship_goals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';

class MyProfileSettings extends ConsumerStatefulWidget {
  const MyProfileSettings({super.key});

  @override
  ConsumerState<MyProfileSettings> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<MyProfileSettings> {
  // Initial/default values
  String? gender = 'male';
  String? maritalStatus = 'single';
  String? showMe = 'men';
  String? relationshipGoal = 'Long-term'; // New state variable
  DateTime? dob = DateTime(2022, 1, 1);
  String? distanceMeasure = 'Km';
  String? homeAddress = '';
  String? nationality = '';
  String? residenceCountry = '';
  String? residenceCity = '';
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
  final List<String> distanceOptions = ['miles', 'Km'];
  
  // Get labels from your constants file
  final List<String> goalOptions = relationshipGoals.map((e) => e.label).toList();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController residenceCityController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(myProfileServiceProviderImpl).data;

      setState(() {
        gender = profile['gender'];
        maritalStatus = profile['marital_status'];
        showMe = profile['show_me'];
        // Handle potential null or case mismatch from API
        relationshipGoal = _matchGoal(profile['relationship_goal']); 
        dob = DateTime.parse(profile['dob']);
        distanceMeasure = profile['distance_measure'];
        addressController.text = profile['home_address'] ?? '';
        nationality = profile['nationality'];
        residenceCountry = profile['residence_country'];
        residenceCity = profile['residence_city'] ?? '';
        residenceCityController.text = profile['residence_city'] ?? '';
      });
    });
  }

  // Helper to ensure the value from DB matches one of our dropdown labels
  String _matchGoal(dynamic value) {
    if (value == null) return goalOptions.first;
    return goalOptions.firstWhere(
      (element) => element.toLowerCase() == value.toString().toLowerCase(),
      orElse: () => goalOptions.first,
    );
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

  void _saveChanges() async {
    setState(() {
      isLoading = true;
    });
    final profileService = ref.read(myProfileServiceProviderImpl);
    final existingData = profileService.data;

    // Merge updated fields with existing profile data
    Map<String, dynamic> updatedData = {
      ...existingData, 
      'gender': gender,
      'marital_status': maritalStatus,
      'show_me': showMe,
      'relationship_goal': relationshipGoal, // Added to persistence logic
      'dob': dob?.toIso8601String().split('T')[0],
      'distance_measure': distanceMeasure,
      'home_address': addressController.text,
      'nationality': nationality,
      'residence_country': residenceCountry,
      'residence_city': residenceCityController.text,
    };

    final myProfile = ref.read(myProfileServiceProviderImpl.notifier);
    await myProfile.updateProfile(TargetProfileModel.fromMapNewNoProfile(updatedData));

    if (mounted) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  // Rest of your helper methods (_buildDropdown, _buildSectionHeader, _buildInfoCard) remain the same...
  Widget _buildDropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF111111)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600),),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              onChanged: onChanged,
              hint: Text(label),
              icon: const Icon(Icons.arrow_drop_down_circle_outlined, size: 20),
              items: options.map((item) {
                return DropdownMenuItem(
                  value: item, 
                  child: Text(
                    // Capitalize only if it's not one of our predefined Goal labels 
                    // (which are already formatted correctly)
                    goalOptions.contains(item) ? item : item[0].toUpperCase() + item.substring(1),
                    style: const TextStyle(fontSize: 16),
                  )
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.light 
              ? Colors.black87 
              : Colors.white70,
        ),
      ),
    );
  }

  Widget _buildInfoCard(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light 
            ? Colors.grey.shade50 
            : const Color(0xFF050505),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light 
              ? Colors.grey.shade200 
              : const Color(0xFF050505),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isLightTheme ? Colors.white : Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_left),
        ),
        title: Text(
          'Edit Profile Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isLightTheme ? Colors.black87 : Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              _buildSectionHeader('Basic Information'),
              _buildInfoCard(
                Column(
                  children: [
                    _buildDropdown('Gender', gender!, genderOptions,
                        (val) => setState(() => gender = val!)),
                    const SizedBox(height: 8),
                    _buildDropdown('Marital Status', maritalStatus!, maritalStatusOptions,
                        (val) => setState(() => maritalStatus = val!)),
                    const SizedBox(height: 8),
                    _buildDropdown('Show Me', showMe!, showMeOptions,
                        (val) => setState(() => showMe = val!)),
                    const SizedBox(height: 8),
                    // NEW: Relationship Goal Dropdown
                    _buildDropdown('Looking For', relationshipGoal!, goalOptions,
                        (val) => setState(() => relationshipGoal = val!)),
                  ],
                ),
              ),
              
              // Personal Details, Location, and Save button code remains identical...
              _buildSectionHeader('Personal Details'),
              _buildInfoCard(
                Column(
                  children: [
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF111111)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cake_outlined, color: GlobalColors.primaryColor, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date of Birth', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  Text(DateFormat('dd MMMM yyyy').format(dob!), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          onSelect: (Country country) => setState(() => nationality = country.name.toUpperCase()),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF111111)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, color: GlobalColors.primaryColor, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nationality', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  Text(nationality ?? 'Select nationality', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.grey.shade400, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              _buildSectionHeader('Location'),
              _buildInfoCard(
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          onSelect: (Country country) => setState(() => residenceCountry = country.name),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF111111)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.public_outlined, color: GlobalColors.primaryColor, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Residence Country', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  Text(residenceCountry ?? 'Select country', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.grey.shade400, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF111111)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: residenceCityController,
                        decoration: InputDecoration(
                          labelText: 'Residence City',
                          prefixIcon: Icon(Icons.location_city_outlined, color: GlobalColors.primaryColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              _buildSectionHeader('Preferences'),
              _buildInfoCard(
                _buildDropdown('Distance Measure', distanceMeasure!, distanceOptions,
                    (val) => setState(() => distanceMeasure = val!)),
              ),
              
              const SizedBox(height: 30),
              
              Container(
                width: double.infinity,
                height: 54,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}