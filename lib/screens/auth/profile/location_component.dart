import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:blisso_mobile/services/location/location_service_provider.dart';
import 'package:country_picker/country_picker.dart';
//import 'package:country_search/country_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationComponent extends ConsumerStatefulWidget {
  final Function onContinue;
  final Function onChangePosition;
  final Function onChangeAddress;
  final Position? location;
  final TextEditingController homeAddress;

  // New controllers for country/city/nationality
  final TextEditingController residenceCountryController;
  final TextEditingController residenceCityController;
  final TextEditingController nationalityController;

  const LocationComponent({
    super.key,
    required this.onChangeAddress,
    required this.onContinue,
    required this.onChangePosition,
    required this.location,
    required this.homeAddress,
    required this.residenceCountryController,
    required this.residenceCityController,
    required this.nationalityController,
  });

  @override
  ConsumerState<LocationComponent> createState() => _LocationComponentState();
}

class _LocationComponentState extends ConsumerState<LocationComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _isGettingLocation = false;

  Country? _residenceCountry;
  Country? _nationality;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      Position position = await ref
          .read(locationServiceProviderImpl.notifier)
          .getLatitudeAndLongitude();
      widget.onChangePosition(position);
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _pickResidenceCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        inputDecoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          hintText: 'Search country',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: GlobalColors.secondaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: GlobalColors.primaryColor, width: 2),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _residenceCountry = country;
          widget.residenceCountryController.text = country.name;
        });
      },
    );
  }

  void _pickNationality() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        inputDecoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          hintText: 'Search nationality',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: GlobalColors.secondaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: GlobalColors.primaryColor, width: 2),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _nationality = country;
          widget.nationalityController.text = country.name;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final size = MediaQuery.sizeOf(context);
    final bool hasLocation = widget.location != null;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.06),
              _StepIndicator(current: 5, total: 8),
              SizedBox(height: size.height * 0.045),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: GlobalColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.location_on_outlined,
                    color: GlobalColors.primaryColor, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                'Where are you?',
                style: TextStyle(
                  fontSize: scaler.scale(28),
                  fontWeight: FontWeight.w700,
                  color: isLight ? const Color(0xFF1A1A2E) : Colors.white,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Help us find people near you and personalise your experience',
                style: TextStyle(
                  fontSize: scaler.scale(13),
                  color: GlobalColors.secondaryColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: size.height * 0.04),

              // GPS Location card
              GestureDetector(
                onTap: _isGettingLocation ? null : _getLocation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: hasLocation
                        ? GlobalColors.primaryColor.withOpacity(0.08)
                        : isLight
                            ? Colors.white
                            : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: hasLocation
                          ? GlobalColors.primaryColor.withOpacity(0.4)
                          : isLight
                              ? const Color(0xFFE8E8E8)
                              : Colors.white24,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: hasLocation
                              ? GlobalColors.primaryColor.withOpacity(0.15)
                              : GlobalColors.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isGettingLocation
                            ? Padding(
                                padding: const EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: GlobalColors.primaryColor,
                                ),
                              )
                            : Icon(
                                hasLocation
                                    ? Icons.my_location_rounded
                                    : Icons.location_searching_rounded,
                                color: hasLocation
                                    ? GlobalColors.primaryColor
                                    : GlobalColors.secondaryColor,
                                size: 22,
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasLocation
                                  ? 'Location detected'
                                  : 'Get GPS location',
                              style: TextStyle(
                                fontSize: scaler.scale(14),
                                fontWeight: FontWeight.w600,
                                color: hasLocation
                                    ? GlobalColors.primaryColor
                                    : isLight
                                        ? const Color(0xFF1A1A2E)
                                        : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasLocation
                                  ? '${widget.location!.latitude.toStringAsFixed(4)}, ${widget.location!.longitude.toStringAsFixed(4)}'
                                  : 'Tap to detect your current location',
                              style: TextStyle(
                                fontSize: scaler.scale(11),
                                color: GlobalColors.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasLocation)
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: GlobalColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Residence Country picker
              _SectionLabel(text: 'Residence Country', scaler: scaler),
              const SizedBox(height: 8),
              _CountryPickerField(
                isLight: isLight,
                scaler: scaler,
                selectedCountry: _residenceCountry,
                placeholder: 'Select your country of residence',
                onTap: _pickResidenceCountry,
              ),

              const SizedBox(height: 14),

              // Residence City
              _SectionLabel(text: 'Residence City', scaler: scaler),
              const SizedBox(height: 8),
              _StyledTextField(
                controller: widget.residenceCityController,
                hint: 'Enter your city',
                icon: Icons.location_city_rounded,
                isLight: isLight,
                scaler: scaler,
              ),

              const SizedBox(height: 14),

              // Nationality picker
              _SectionLabel(text: 'Nationality', scaler: scaler),
              const SizedBox(height: 8),
              _CountryPickerField(
                isLight: isLight,
                scaler: scaler,
                selectedCountry: _nationality,
                placeholder: 'Select your nationality',
                onTap: _pickNationality,
              ),

              SizedBox(height: size.height * 0.04),

              _PrimaryButton(
                text: 'Continue',
                onTap: () {
                  if (widget.location == null) {
                    showPopupComponent(
                        context: context,
                        icon: Icons.location_off_rounded,
                        message:
                            'Please tap "Get GPS location" to detect your location');
                    return;
                  }
                  if (widget.residenceCountryController.text.isEmpty) {
                    showPopupComponent(
                        context: context,
                        icon: Icons.flag_outlined,
                        message: 'Please select your country of residence');
                    return;
                  }
                  if (widget.residenceCityController.text.trim().isEmpty) {
                    showPopupComponent(
                        context: context,
                        icon: Icons.location_city_outlined,
                        message: 'Please enter your residence city');
                    return;
                  }
                  if (widget.nationalityController.text.isEmpty) {
                    showPopupComponent(
                        context: context,
                        icon: Icons.public_outlined,
                        message: 'Please select your nationality');
                    return;
                  }
                  widget.onContinue();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final TextScaler scaler;
  const _SectionLabel({required this.text, required this.scaler});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: scaler.scale(12),
        fontWeight: FontWeight.w600,
        color: GlobalColors.secondaryColor,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _CountryPickerField extends StatelessWidget {
  final bool isLight;
  final TextScaler scaler;
  final Country? selectedCountry;
  final String placeholder;
  final VoidCallback onTap;

  const _CountryPickerField({
    required this.isLight,
    required this.scaler,
    required this.selectedCountry,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selectedCountry != null
                ? GlobalColors.primaryColor.withOpacity(0.5)
                : isLight
                    ? const Color(0xFFE0E0E0)
                    : Colors.white24,
            width: selectedCountry != null ? 2 : 1.5,
          ),
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            if (selectedCountry != null) ...[
              Text(
                selectedCountry!.flagEmoji,
                style: TextStyle(fontSize: scaler.scale(20)),
              ),
              const SizedBox(width: 12),
            ] else ...[
              Icon(Icons.flag_outlined,
                  color: GlobalColors.secondaryColor.withOpacity(0.6),
                  size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                selectedCountry?.name ?? placeholder,
                style: TextStyle(
                  fontSize: scaler.scale(14),
                  fontWeight: selectedCountry != null
                      ? FontWeight.w500
                      : FontWeight.w400,
                  color: selectedCountry != null
                      ? (isLight ? const Color(0xFF1A1A2E) : Colors.white)
                      : GlobalColors.secondaryColor.withOpacity(0.6),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: GlobalColors.secondaryColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _StyledTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isLight;
  final TextScaler scaler;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isLight,
    required this.scaler,
  });

  @override
  State<_StyledTextField> createState() => _StyledTextFieldState();
}

class _StyledTextFieldState extends State<_StyledTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isLight
              ? Colors.white
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isFocused
                ? GlobalColors.primaryColor
                : widget.isLight
                    ? const Color(0xFFE0E0E0)
                    : Colors.white24,
            width: _isFocused ? 2 : 1.5,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: GlobalColors.primaryColor.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  )
                ]
              : widget.isLight
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
        ),
        child: TextField(
          controller: widget.controller,
          style: TextStyle(
            fontSize: widget.scaler.scale(14),
            fontWeight: FontWeight.w500,
            color: widget.isLight ? const Color(0xFF1A1A2E) : Colors.white,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: GlobalColors.secondaryColor.withOpacity(0.6),
              fontSize: widget.scaler.scale(14),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              widget.icon,
              color: _isFocused
                  ? GlobalColors.primaryColor
                  : GlobalColors.secondaryColor,
              size: 20,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }
}

// Shared widgets
class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i + 1 == current;
        final done = i + 1 < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 6),
          height: 4,
          width: active ? 28 : 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: active
                ? GlobalColors.primaryColor
                : done
                    ? GlobalColors.primaryColor.withOpacity(0.4)
                    : GlobalColors.secondaryColor.withOpacity(0.2),
          ),
        );
      }),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PrimaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: GlobalColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed) ? 2 : 8),
          shadowColor: WidgetStateProperty.all(
              GlobalColors.primaryColor.withOpacity(0.4)),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3)),
      ),
    );
  }
}