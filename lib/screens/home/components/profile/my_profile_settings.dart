import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/my_profile_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:country_search/country_search.dart';

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

  final TextEditingController addressController = TextEditingController();
  final TextEditingController residenceCityController = TextEditingController();
  
  Country? _selectedNationality;
  Country? _selectedResidenceCountry;

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
        addressController.text = profile['home_address'] ?? '';
        nationality = profile['nationality'];
        residenceCountry = profile['residence_country'];
        residenceCity = profile['residence_city'] ?? '';
        residenceCityController.text = profile['residence_city'] ?? '';
        
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

  void _saveChanges() async {
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

  Widget _buildDropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF111111)),
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
                    item[0].toUpperCase() + item.substring(1),
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
            : Color(0xFF050505),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light 
              ? Colors.grey.shade200 
              : Color(0xFF050505),
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
        leading: Container(
          margin: const EdgeInsets.all(8),
          
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.keyboard_arrow_left),
          ),
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
              // Basic Information Section
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
                  ],
                ),
              ),
              
              // Personal Details Section
              _buildSectionHeader('Personal Details'),
              _buildInfoCard(
                Column(
                  children: [
                    // Date of Birth
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF111111)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cake_outlined,
                              color: GlobalColors.primaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date of Birth',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd MMMM yyyy').format(dob!),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey.shade400,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Nationality
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CountryPicker(
                        selectedCountry: _selectedNationality,
                        onCountrySelected: (Country country) {
                          setState(() {
                            _selectedNationality = country;
                            nationality = country.getDisplayName(context).toUpperCase();
                          });
                        },
                        showPhoneCodes: false,
                        showCountryCodes: false,
                        labelText: 'Nationality - ${_selectedNationality == null ? nationality : _selectedNationality?.getDisplayName(context).toUpperCase()}',
                        hintText: 'Change your nationality',
                        backgroundColor: isLightTheme ? Colors.white : Colors.black,
                        textColor: isLightTheme ? Colors.black : Colors.white,
                        accentColor: GlobalColors.primaryColor,
                        itemHeight: 56,
                        flagSize: 24,
                        borderRadius: 8,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Location Section
              _buildSectionHeader('Location'),
              _buildInfoCard(
                Column(
                  children: [
                    // Residence Country
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CountryPicker(
                        selectedCountry: _selectedResidenceCountry,
                        onCountrySelected: (Country country) {
                          setState(() {
                            _selectedResidenceCountry = country;
                          });
                        },
                        showPhoneCodes: false,
                        showCountryCodes: false,
                        labelText: 'Residence Country - ${_selectedResidenceCountry == null ? residenceCountry : _selectedResidenceCountry?.getDisplayName(context)}',
                        hintText: 'Change your country of residence',
                        backgroundColor: isLightTheme ? Colors.white : Colors.black,
                        textColor: isLightTheme ? Colors.black : Colors.white,
                        accentColor: GlobalColors.primaryColor,
                        itemHeight: 56,
                        flagSize: 24,
                        borderRadius: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Residence City
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF111111)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: residenceCityController,
                        decoration: InputDecoration(
                          labelText: 'Residence City',
                          hintText: 'Enter your city',
                          prefixIcon: Icon(
                            Icons.location_city_outlined,
                            color: GlobalColors.primaryColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Home Address
                    // Container(
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: Colors.grey.shade300),
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: TextFormField(
                    //     controller: addressController,
                    //     decoration: InputDecoration(
                    //       labelText: 'Home Address',
                    //       hintText: 'Enter your home address',
                    //       prefixIcon: Icon(
                    //         Icons.home_outlined,
                    //         color: GlobalColors.primaryColor,
                    //       ),
                    //       border: InputBorder.none,
                    //       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              
              // Preferences Section
              _buildSectionHeader('Preferences'),
              _buildInfoCard(
                _buildDropdown('Distance Measure', distanceMeasure!, distanceOptions,
                    (val) => setState(() => distanceMeasure = val!)),
              ),
              
              const SizedBox(height: 30),
              
              // Save Button
              Container(
                width: double.infinity,
                height: 54,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}