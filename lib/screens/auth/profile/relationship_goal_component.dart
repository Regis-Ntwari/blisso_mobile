import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:blisso_mobile/utils/relationship_goals.dart';
import 'package:flutter/material.dart';

class RelationshipGoalComponent extends StatefulWidget {
  final String chosenGoal;
  final Function(String) changeGoal;
  final VoidCallback onContinue;

  const RelationshipGoalComponent({
    super.key,
    required this.chosenGoal,
    required this.changeGoal,
    required this.onContinue,
  });

  @override
  State<RelationshipGoalComponent> createState() => _RelationshipGoalComponentState();
}

class _RelationshipGoalComponentState extends State<RelationshipGoalComponent> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
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
    final scaler = MediaQuery.textScalerOf(context);
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
              SizedBox(height: size.height * 0.04),
              const _StepIndicator(current: 7, total: 8), // Updated total steps
              SizedBox(height: size.height * 0.03),
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: GlobalColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.search_rounded, color: GlobalColors.primaryColor, size: 28),
              ),
              const SizedBox(height: 20),
              Text('What are you looking for?',
                style: TextStyle(fontSize: scaler.scale(26), fontWeight: FontWeight.w700,
                  color: isLight ? const Color(0xFF1A1A2E) : Colors.white, height: 1.2, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text('Help us find the right matches for you',
                style: TextStyle(fontSize: scaler.scale(13), color: GlobalColors.secondaryColor, height: 1.5)),
              SizedBox(height: size.height * 0.03),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5),
                itemCount: relationshipGoals.length,
                itemBuilder: (context, index) {
                  final goal = relationshipGoals[index];
                  final isSelected = widget.chosenGoal == goal.label;
                  return GestureDetector(
                    onTap: () => widget.changeGoal(goal.label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? GlobalColors.primaryColor : isLight ? Colors.white : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isSelected ? GlobalColors.primaryColor : isLight ? const Color(0xFFE8E8E8) : Colors.white12, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(goal.icon, size: 20, color: isSelected ? Colors.white : GlobalColors.primaryColor),
                          const SizedBox(height: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(goal.label, style: TextStyle(fontSize: scaler.scale(12), fontWeight: FontWeight.w600, color: isSelected ? Colors.white : (isLight ? const Color(0xFF1A1A2E) : Colors.white))),
                              Text(goal.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: scaler.scale(9), color: isSelected ? Colors.white70 : GlobalColors.secondaryColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: size.height * 0.04),
              _PrimaryButton(
                text: 'Submit',
                onTap: () {
                  if (widget.chosenGoal.isEmpty) {
                    showPopupComponent(context: context, icon: Icons.info_outline, message: 'Please select what you are looking for');
                  } else {
                    widget.onContinue();
                  }
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

// Reuse the _StepIndicator and _PrimaryButton from your MaritalStatus component or move them to shared components

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