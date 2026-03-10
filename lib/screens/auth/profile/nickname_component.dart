import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class NicknameComponent extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final VoidCallback onContinue;

  const NicknameComponent({
    super.key,
    required this.formKey,
    required this.onContinue,
    required this.controller,
  });

  @override
  State<NicknameComponent> createState() => _NicknameComponentState();
}

class _NicknameComponentState extends State<NicknameComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final size = MediaQuery.sizeOf(context);

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
              // Step indicator
              _StepIndicator(current: 1, total: 7),
              SizedBox(height: size.height * 0.045),
              // Icon accent
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: GlobalColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person_outline_rounded,
                    color: GlobalColors.primaryColor, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.nicknameTitle,
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
                AppLocalizations.of(context)!.nicknameSubtitle,
                style: TextStyle(
                  fontSize: scaler.scale(13),
                  color: GlobalColors.secondaryColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Form(
                key: widget.formKey,
                child: Focus(
                  onFocusChange: (hasFocus) =>
                      setState(() => _isFocused = hasFocus),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isFocused
                            ? GlobalColors.primaryColor
                            : (isLight
                                ? const Color(0xFFE0E0E0)
                                : Colors.white24),
                        width: _isFocused ? 2 : 1.5,
                      ),
                      color: isLight ? Colors.white : Colors.white.withOpacity(0.05),
                      boxShadow: _isFocused
                          ? [
                              BoxShadow(
                                color: GlobalColors.primaryColor.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: TextFormField(
                      controller: widget.controller,
                      style: TextStyle(
                        fontSize: scaler.scale(16),
                        fontWeight: FontWeight.w500,
                        color: isLight ? const Color(0xFF1A1A2E) : Colors.white,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        border: InputBorder.none,
                        hintText: AppLocalizations.of(context)!.hintNickname,
                        hintStyle: TextStyle(
                          color: GlobalColors.secondaryColor.withOpacity(0.6),
                          fontSize: scaler.scale(15),
                        ),
                        prefixIcon: Icon(Icons.alternate_email_rounded,
                            color: _isFocused
                                ? GlobalColors.primaryColor
                                : GlobalColors.secondaryColor,
                            size: 20),
                        errorStyle: TextStyle(
                            fontSize: scaler.scale(11),
                            color: Colors.redAccent),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return AppLocalizations.of(context)!.validatorNickname1;
                        }
                        if (value.trim().length < 3) {
                          return AppLocalizations.of(context)!.validatorNickname2;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              _PrimaryButton(
                text: AppLocalizations.of(context)!.continuei,
                onTap: () {
                  if (widget.formKey.currentState!.validate()) {
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

// ─── Shared Widgets ──────────────────────────────────────────────────────────

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: GlobalColors.primaryColor.withOpacity(0.4),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.pressed) ? 2 : 8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}