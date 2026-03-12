import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

const int kMinRequiredSelections = 5;

class ProfileSnapshotsComponent extends ConsumerStatefulWidget {
  final List<int> chosenValues;
  final Function checkInterest;
  final Function toggleInterest;
  final List<Map<String, List<Map<String, dynamic>>>> values;

  const ProfileSnapshotsComponent({
    super.key,
    required this.chosenValues,
    required this.checkInterest,
    required this.toggleInterest,
    required this.values,
  });

  @override
  ConsumerState<ProfileSnapshotsComponent> createState() =>
      _ProfileSnapshotsComponentState();
}

class _ProfileSnapshotsComponentState
    extends ConsumerState<ProfileSnapshotsComponent>
    with SingleTickerProviderStateMixin {
  int detailsIndex = 0;
  late List<Map<String, List<Map<String, dynamic>>>> _filteredValues;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _copyList();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.05, 0),
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
  void didUpdateWidget(covariant ProfileSnapshotsComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      setState(() {
        _filteredValues = widget.values
            .map((e) => Map<String, List<Map<String, dynamic>>>.from(e))
            .toList();
      });
    }
  }

  void _copyList() {
    _filteredValues = widget.values
        .map((e) => Map<String, List<Map<String, dynamic>>>.from(e))
        .toList();
  }

  void _navigate(int dir) {
    final next = detailsIndex + dir;
    if (next >= 0 && next < _filteredValues.length) {
      setState(() => detailsIndex = next);
      _animController.forward(from: 0);
    }
  }

  bool get _canSubmit => widget.chosenValues.length >= kMinRequiredSelections;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final scaler = MediaQuery.textScalerOf(context);

    if (_filteredValues.isEmpty) return const SizedBox.shrink();

    final catKey = _filteredValues[detailsIndex].keys.first;
    final items = _filteredValues[detailsIndex][catKey] ?? [];

    // ── Palette: pure black / white ──────────────────────────────────────
    final bg       = isLight ? Colors.white          : Colors.black;
    final cardBg   = isLight ? const Color(0xFFF2F2F2) : const Color(0xFF0E0E0E);
    final border   = isLight ? const Color(0xFFDDDDDD) : const Color(0xFF242424);
    final textMain = isLight ? Colors.black          : Colors.white;
    final textDim  = isLight ? const Color(0xFF888888) : const Color(0xFF555555);
    final accent   = GlobalColors.primaryColor;

    final remaining = kMinRequiredSelections - widget.chosenValues.length;
    final progress =
        (widget.chosenValues.length / kMinRequiredSelections).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: textDim.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Title + subtitle ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 2),
            child: Column(
              children: [
                Text(
                  'Choose Your Attributes',
                  style: TextStyle(
                    fontSize: scaler.scale(19),
                    fontWeight: FontWeight.w800,
                    color: textMain,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select at least $kMinRequiredSelections that describe you',
                  style: TextStyle(
                    fontSize: scaler.scale(12),
                    color: textDim,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // ── Category progress bar (replaces dots — no overflow risk) ────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
            child: Row(
              children: [
                Text(
                  '${detailsIndex + 1} of ${_filteredValues.length}',
                  style: TextStyle(
                    fontSize: scaler.scale(11),
                    color: textDim,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (detailsIndex + 1) / _filteredValues.length,
                      minHeight: 3,
                      backgroundColor: border,
                      valueColor: AlwaysStoppedAnimation<Color>(textDim),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Category navigator ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  _NavBtn(
                    icon: Icons.chevron_left_rounded,
                    enabled: detailsIndex > 0,
                    onTap: () => _navigate(-1),
                    isLight: isLight,
                  ),
                  Expanded(
                    child: Text(
                      catKey,
                      style: TextStyle(
                        fontSize: scaler.scale(13),
                        fontWeight: FontWeight.w700,
                        color: textMain,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _NavBtn(
                    icon: Icons.chevron_right_rounded,
                    enabled: detailsIndex < _filteredValues.length - 1,
                    onTap: () => _navigate(1),
                    isLight: isLight,
                  ),
                ],
              ),
            ),
          ),

          // ── Scrollable grid ─────────────────────────────────────────────
          Flexible(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.7,
                    ),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      final selected = widget.checkInterest(item) as bool;
                      return _Chip(
                        label: item['name']?.toString() ?? '',
                        isSelected: selected,
                        onTap: () => widget.toggleInterest(item),
                        cardBg: cardBg,
                        border: border,
                        textMain: textMain,
                        textDim: textDim,
                        accent: accent,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // ── Footer: selection counter + submit ──────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
            decoration: BoxDecoration(
              color: bg,
              border: Border(top: BorderSide(color: border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mini progress row
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _canSubmit ? Colors.green.shade400 : accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _canSubmit
                            ? '${widget.chosenValues.length} selected ✓'
                            : '${widget.chosenValues.length} / $kMinRequiredSelections',
                        style: TextStyle(
                          fontSize: scaler.scale(11),
                          fontWeight: FontWeight.w700,
                          color: _canSubmit ? Colors.green.shade400 : textDim,
                        ),
                      ),
                    ],
                  ),
                ),

                // Button — always rendered, dims + ignores taps when below min
                AnimatedOpacity(
                  opacity: _canSubmit ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_canSubmit,
                    child: ButtonComponent(
                      text: _canSubmit
                          ? 'Continue →'
                          : 'Select $remaining more to continue',
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      onTap: () {
                        ref
                            .read(snapshotServiceProviderImpl.notifier)
                            .postMyProfileSnapshots(widget.chosenValues);

                        final state = ref.read(snapshotServiceProviderImpl);
                        if (state.error != null) {
                          showSnackBar(context, state.error!);
                        } else {
                          Routemaster.of(context).push(
                            '/auto-write/What do you want in your lover.../target-snapshot',
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool isLight;

  const _NavBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? (isLight
                  ? Colors.black.withOpacity(0.07)
                  : Colors.white.withOpacity(0.07))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? (isLight ? Colors.black : Colors.white)
              : (isLight
                  ? Colors.black.withOpacity(0.18)
                  : Colors.white.withOpacity(0.18)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color cardBg;
  final Color border;
  final Color textMain;
  final Color textDim;
  final Color accent;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.cardBg,
    required this.border,
    required this.textMain,
    required this.textDim,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.08) : cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accent : border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? accent : textDim,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Icon(Icons.check_circle_rounded,
                    size: 11, color: accent),
              ),
          ],
        ),
      ),
    );
  }
}