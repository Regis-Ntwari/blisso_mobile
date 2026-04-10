import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class GenderComponent extends StatefulWidget {
  final List<String> genders;
  final String chosenGender;
  final Function changeGender;
  final VoidCallback onContinue;

  const GenderComponent({
    super.key,
    required this.genders,
    required this.chosenGender,
    required this.changeGender,
    required this.onContinue,
  });

  @override
  State<GenderComponent> createState() => _GenderComponentState();
}

class _GenderComponentState extends State<GenderComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final Map<String, _GenderData> _genderMeta = {
    'MALE': _GenderData(Icons.male_rounded, 'He/Him'),
    'FEMALE': _GenderData(Icons.female_rounded, 'She/Her'),
  };

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
              _StepIndicator(current: 3, total: 8),
              SizedBox(height: size.height * 0.045),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: GlobalColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.wc_rounded,
                    color: GlobalColors.primaryColor, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.genderTitle,
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
                'Select the gender you identify with',
                style: TextStyle(
                  fontSize: scaler.scale(13),
                  color: GlobalColors.secondaryColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              ...widget.genders.map((gender) {
                final isSelected = widget.chosenGender == gender;
                final meta = _genderMeta[gender] ??
                    _GenderData(Icons.person_outline, '');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GestureDetector(
                    onTap: () => widget.changeGender(gender),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? GlobalColors.primaryColor
                            : isLight
                                ? Colors.white
                                : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? GlobalColors.primaryColor
                              : isLight
                                  ? const Color(0xFFE8E8E8)
                                  : Colors.white12,
                          width: isSelected ? 0 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      GlobalColors.primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            : isLight
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : GlobalColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              meta.icon,
                              color: isSelected
                                  ? Colors.white
                                  : GlobalColors.primaryColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gender[0] +
                                    gender.substring(1).toLowerCase(),
                                style: TextStyle(
                                  fontSize: scaler.scale(17),
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : isLight
                                          ? const Color(0xFF1A1A2E)
                                          : Colors.white,
                                ),
                              ),
                              if (meta.pronoun.isNotEmpty)
                                Text(
                                  meta.pronoun,
                                  style: TextStyle(
                                    fontSize: scaler.scale(12),
                                    color: isSelected
                                        ? Colors.white70
                                        : GlobalColors.secondaryColor,
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : isLight
                                        ? const Color(0xFFD0D0D0)
                                        : Colors.white38,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(Icons.check_rounded,
                                    size: 14,
                                    color: GlobalColors.primaryColor)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: size.height * 0.03),
              _PrimaryButton(
                text: AppLocalizations.of(context)!.continuei,
                onTap: () {
                  if (widget.chosenGender == '') {
                    showPopupComponent(
                        context: context,
                        icon: Icons.dangerous,
                        message: 'Please choose your gender');
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

class _GenderData {
  final IconData icon;
  final String pronoun;
  const _GenderData(this.icon, this.pronoun);
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