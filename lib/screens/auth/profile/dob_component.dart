import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';

class DobComponent extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController dayController;
  final TextEditingController monthController;
  final TextEditingController yearController;
  final FocusNode dayFocusNode;
  final FocusNode monthFocusNode;
  final FocusNode yearFocusNode;
  final VoidCallback onTap;

  const DobComponent({
    super.key,
    required this.formKey,
    required this.dayController,
    required this.monthController,
    required this.yearController,
    required this.dayFocusNode,
    required this.monthFocusNode,
    required this.yearFocusNode,
    required this.onTap,
  });

  @override
  State<DobComponent> createState() => _DobComponentState();
}

class _DobComponentState extends State<DobComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
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
          child: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.06),
                _StepIndicator(current: 2, total: 8),
                SizedBox(height: size.height * 0.045),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: GlobalColors.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.cake_outlined,
                      color: GlobalColors.primaryColor, size: 28),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.dateOfBirthTitle,
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
                  'Tell us when you were born',
                  style: TextStyle(
                    fontSize: scaler.scale(13),
                    color: GlobalColors.secondaryColor,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: size.height * 0.05),

                // Day + Year row
                Row(
                  children: [
                    // Day
                    Expanded(
                      child: _DateField(
                        controller: widget.dayController,
                        focusNode: widget.dayFocusNode,
                        label: 'Day',
                        hint: 'DD',
                        maxLength: 2,
                        isLight: isLight,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.dayValidator1;
                          }
                          final day = int.tryParse(value);
                          if (day == null || day < 1 || day > 31) {
                            return AppLocalizations.of(context)!.dayValidator2;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.length == 2) {
                            FocusScope.of(context)
                                .requestFocus(widget.monthFocusNode);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Year
                    Expanded(
                      flex: 2,
                      child: _DateField(
                        controller: widget.yearController,
                        focusNode: widget.yearFocusNode,
                        label: 'Year',
                        hint: 'YYYY',
                        maxLength: 4,
                        isLight: isLight,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.yearValidator1;
                          }
                          final year = int.tryParse(value);
                          if (year == null ||
                              year < 1900 ||
                              year > DateTime.now().year) {
                            return AppLocalizations.of(context)!.yearValidator2;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.length == 4) {
                            FocusScope.of(context).unfocus();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Month selector
                FormField<int>(
                  validator: (_) {
                    if (_selectedMonth == null) {
                      return AppLocalizations.of(context)!.monthValidator1;
                    }
                    return null;
                  },
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Month',
                          style: TextStyle(
                            fontSize: scaler.scale(12),
                            fontWeight: FontWeight.w600,
                            color: GlobalColors.secondaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(12, (i) {
                            final selected = _selectedMonth == i + 1;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMonth = i + 1;
                                  widget.monthController.text =
                                      (i + 1).toString().padLeft(2, '0');
                                });
                                field.didChange(i + 1);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? GlobalColors.primaryColor
                                      : isLight
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? GlobalColors.primaryColor
                                        : isLight
                                            ? const Color(0xFFE0E0E0)
                                            : Colors.white24,
                                    width: 1.5,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: GlobalColors.primaryColor
                                                .withOpacity(0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  _monthNames[i],
                                  style: TextStyle(
                                    fontSize: scaler.scale(13),
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selected
                                        ? Colors.white
                                        : isLight
                                            ? const Color(0xFF1A1A2E)
                                            : Colors.white70,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              field.errorText!,
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: scaler.scale(11)),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                SizedBox(height: size.height * 0.05),
                _PrimaryButton(
                    text: AppLocalizations.of(context)!.continuei,
                    onTap: () {
                      if (widget.formKey.currentState!.validate()) {
                        final day = int.tryParse(widget.dayController.text);
                        final month = int.tryParse(widget.monthController.text);
                        final year = int.tryParse(widget.yearController.text);

                        if (day != null && month != null && year != null) {
                          final dob = DateTime(year, month, day);
                          final today = DateTime.now();

                          int age = today.year - dob.year;

                          // Adjust if birthday hasn't occurred yet this year
                          if (today.month < dob.month ||
                              (today.month == dob.month &&
                                  today.day < dob.day)) {
                            age--;
                          }

                          if (age < 18) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('You must be at least 18 years old'),
                              ),
                            );
                            return;
                          }

                          widget.onTap(); // proceed only if valid
                        }
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final int maxLength;
  final bool isLight;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  const _DateField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.maxLength,
    required this.isLight,
    this.validator,
    this.onChanged,
  });

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => _isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: scaler.scale(12),
            fontWeight: FontWeight.w600,
            color: GlobalColors.secondaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isFocused
                  ? GlobalColors.primaryColor
                  : widget.isLight
                      ? const Color(0xFFE0E0E0)
                      : Colors.white24,
              width: _isFocused ? 2 : 1.5,
            ),
            color:
                widget.isLight ? Colors.white : Colors.white.withOpacity(0.05),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: GlobalColors.primaryColor.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            maxLength: widget.maxLength,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: scaler.scale(18),
              fontWeight: FontWeight.w600,
              color: widget.isLight ? const Color(0xFF1A1A2E) : Colors.white,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: GlobalColors.secondaryColor.withOpacity(0.5),
                fontWeight: FontWeight.w400,
                fontSize: scaler.scale(14),
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            validator: widget.validator,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}

// Shared widgets (same file for brevity - in production, move to shared file)
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
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed) ? 2 : 8),
          shadowColor: WidgetStateProperty.all(
              GlobalColors.primaryColor.withOpacity(0.4)),
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
