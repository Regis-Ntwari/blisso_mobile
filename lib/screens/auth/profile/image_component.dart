import 'dart:io';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageComponent extends StatefulWidget {
  final Function changeProfilePicture;
  final Function onContinue;
  final File? profilePicture;

  const ImageComponent({
    super.key,
    required this.profilePicture,
    required this.changeProfilePicture,
    required this.onContinue,
  });

  @override
  State<ImageComponent> createState() => _ImageComponentState();
}

class _ImageComponentState extends State<ImageComponent>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      widget.changeProfilePicture(File(pickedFile.path));
    }
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bool isLight =
            Theme.of(context).brightness == Brightness.light;
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GlobalColors.secondaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Add a photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isLight ? const Color(0xFF1A1A2E) : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to add your profile picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: GlobalColors.secondaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _SheetOption(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        isLight: isLight,
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SheetOption(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        isLight: isLight,
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final size = MediaQuery.sizeOf(context);
    final hasPhoto = widget.profilePicture != null;

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
              _StepIndicator(current: 6, total: 8),
              SizedBox(height: size.height * 0.045),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: GlobalColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.photo_camera_outlined,
                    color: GlobalColors.primaryColor, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                'Your best photo',
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
                'Add a clear photo so people can recognise you',
                style: TextStyle(
                  fontSize: scaler.scale(13),
                  color: GlobalColors.secondaryColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: size.height * 0.04),

              // Photo display
              Center(
                child: GestureDetector(
                  onTap: _showPickerSheet,
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: size.width * 0.55,
                        height: size.width * 0.55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasPhoto
                              ? Colors.transparent
                              : isLight
                                  ? const Color(0xFFF5F5F5)
                                  : Colors.white.withOpacity(0.06),
                          border: Border.all(
                            color: hasPhoto
                                ? GlobalColors.primaryColor.withOpacity(0.5)
                                : isLight
                                    ? const Color(0xFFE0E0E0)
                                    : Colors.white24,
                            width: hasPhoto ? 3 : 2,
                          ),
                          boxShadow: hasPhoto
                              ? [
                                  BoxShadow(
                                    color: GlobalColors.primaryColor
                                        .withOpacity(0.2),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  )
                                ]
                              : [],
                          image: hasPhoto
                              ? DecorationImage(
                                  image: FileImage(widget.profilePicture!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: hasPhoto
                            ? null
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: GlobalColors.secondaryColor
                                        .withOpacity(0.6),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to add photo',
                                    style: TextStyle(
                                      fontSize: scaler.scale(12),
                                      color: GlobalColors.secondaryColor
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      // Edit button overlay
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: _showPickerSheet,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: GlobalColors.primaryColor,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: GlobalColors.primaryColor
                                      .withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.04),

              // Tips
              if (!hasPhoto)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GlobalColors.primaryColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: GlobalColors.primaryColor.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: GlobalColors.primaryColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'A clear, bright face photo helps you get more matches',
                          style: TextStyle(
                            fontSize: scaler.scale(12),
                            color: GlobalColors.primaryColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: size.height * 0.04),

              _PrimaryButton(
                text: 'Continue',
                onTap: () {
                  if (!hasPhoto) {
                    showPopupComponent(
                        context: context,
                        icon: Icons.photo_camera_outlined,
                        message: 'Please add a profile photo to continue');
                  } else {
                    widget.onContinue();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLight;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.isLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: GlobalColors.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: GlobalColors.primaryColor.withOpacity(0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: GlobalColors.primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GlobalColors.primaryColor,
              ),
            ),
          ],
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