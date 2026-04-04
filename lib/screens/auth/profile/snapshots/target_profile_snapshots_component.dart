import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

const int kMinTargetSelections = 5;

class TargetProfileSnapshotsComponent extends ConsumerStatefulWidget {
  const TargetProfileSnapshotsComponent({super.key});

  @override
  ConsumerState<TargetProfileSnapshotsComponent> createState() =>
      _TargetProfileSnapshotsComponentState();
}

class _TargetProfileSnapshotsComponentState
    extends ConsumerState<TargetProfileSnapshotsComponent>
    with SingleTickerProviderStateMixin {
  int detailsIndex = 0;

  // First entry is a placeholder sentinel – kept for API compatibility
  final List<Map<String, dynamic>> _chosenValues = [{}];

  List<Map<String, List<Map<String, dynamic>>>> _filteredValues = [];
  List<Map<String, List<Map<String, dynamic>>>> _originalList = [];

  late TextEditingController _searchCtrl;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    // Header entrance — reuse same controller with delay via interval
    _headerFade = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _animCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchSnapshots());
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data helpers ──────────────────────────────────────────────────────────

  Future<void> _fetchSnapshots() async {
    await ref.read(snapshotServiceProviderImpl.notifier).getLifeSnapshots();
    final response = ref.read(snapshotServiceProviderImpl);
    if (mounted) {
      setState(() {
        _originalList = _buildList(response.data ?? []);
      });
      _copyList(_originalList);
    }
  }

  List<Map<String, List<Map<String, dynamic>>>> _buildList(
      List<dynamic> data) {
    final List<Map<String, List<Map<String, dynamic>>>> grouped = [];
    for (final item in data) {
      final sub = item['sub_category'] as String? ?? 'Other';
      final existing = grouped.firstWhere(
        (e) => e.containsKey(sub),
        orElse: () => {},
      );
      if (existing.isNotEmpty) {
        existing[sub]!.add(Map<String, dynamic>.from(item));
      } else {
        grouped.add({
          sub: [Map<String, dynamic>.from(item)]
        });
      }
    }
    return grouped;
  }

  void _copyList(List<Map<String, List<Map<String, dynamic>>>> list) {
    setState(() {
      _filteredValues = list
          .map((e) => Map<String, List<Map<String, dynamic>>>.from(e))
          .toList();
    });
  }

  void _onSearchChange(int idx, String catKey) {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredValues[idx][catKey] = _originalList[idx][catKey]!
          .where((e) => e['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  void _navigate(int dir) {
    final next = detailsIndex + dir;
    if (next >= 0 && next < _originalList.length) {
      setState(() {
        detailsIndex = next;
        _searchCtrl.clear();
      });
      _copyList(_originalList);
      _animCtrl.forward(from: 0);
    }
  }

  // ── Scale helpers ─────────────────────────────────────────────────────────

  double _getScale(Map<String, dynamic> attr) {
    for (final v in _chosenValues) {
      if (v['id'] == attr['id']) return (v['scale'] as num).toDouble();
    }
    return 0;
  }

  bool _hasScale(Map<String, dynamic> attr) => _getScale(attr) > 0;

  void _showScaleDialog(
      BuildContext context, Map<String, dynamic> attr, bool isLight) {
    int idx = _chosenValues.indexWhere((e) => e['id'] == attr['id']);
    if (idx == -1) {
      _chosenValues.add({'id': attr['id'], 'scale': 0.0});
      idx = _chosenValues.length - 1;
    }

    final bg       = isLight ? Colors.white : Colors.black;
    final textMain = isLight ? Colors.black : Colors.white;
    final textDim  = isLight ? const Color(0xFF888888) : const Color(0xFF555555);
    final border   = isLight ? const Color(0xFFDDDDDD) : const Color(0xFF242424);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Dialog(
          backgroundColor: bg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label
                Text(
                  attr['name'] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textMain,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'How important is this to you?',
                  style: TextStyle(fontSize: 12.5, color: textDim),
                ),
                const SizedBox(height: 24),

                // Scale value badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: _chosenValues[idx]['scale'] > 0
                        ? GlobalColors.primaryColor.withOpacity(0.1)
                        : border.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _chosenValues[idx]['scale'] > 0
                          ? GlobalColors.primaryColor
                          : border,
                    ),
                  ),
                  child: Text(
                    _chosenValues[idx]['scale'] == 0
                        ? 'Not important'
                        : _scaleLabel(
                            (_chosenValues[idx]['scale'] as num).toInt()),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _chosenValues[idx]['scale'] > 0
                          ? GlobalColors.primaryColor
                          : textDim,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: GlobalColors.primaryColor,
                    inactiveTrackColor: border,
                    thumbColor: GlobalColors.primaryColor,
                    overlayColor:
                        GlobalColors.primaryColor.withOpacity(0.12),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value:
                        (_chosenValues[idx]['scale'] as num).toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    onChanged: (v) {
                      setDlg(() => _chosenValues[idx]['scale'] = v);
                      setState(() {});
                    },
                  ),
                ),

                // Min / max labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0', style: TextStyle(fontSize: 11, color: textDim)),
                      Text('10',
                          style: TextStyle(fontSize: 11, color: textDim)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // OK button
                SizedBox(
                  width: double.infinity,
                  child: ButtonComponent(
                    text: 'Confirm',
                    backgroundColor: GlobalColors.primaryColor,
                    foregroundColor: Colors.white,
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _scaleLabel(int v) {
    if (v <= 2) return 'Slightly ($v/10)';
    if (v <= 4) return 'Somewhat ($v/10)';
    if (v <= 6) return 'Important ($v/10)';
    if (v <= 8) return 'Very important ($v/10)';
    return 'Must-have ($v/10)';
  }

  // ── Submit helpers ────────────────────────────────────────────────────────

  int get _realSelections =>
      _chosenValues.where((m) => m.isNotEmpty && (m['scale'] ?? 0) > 0).length;

  bool get _canSubmit => _realSelections >= kMinTargetSelections;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(snapshotServiceProviderImpl);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final scaler = MediaQuery.textScalerOf(context);

    if (snapshot.isLoading || _filteredValues.isEmpty) {
      return const LoadingScreen();
    }

    final catKey = _filteredValues[detailsIndex].keys.first;
    final items = _filteredValues[detailsIndex][catKey] ?? [];

    // Palette
    final bg       = isLight ? Colors.white : Colors.black;
    final cardBg   = isLight ? const Color(0xFFF2F2F2) : const Color(0xFF0E0E0E);
    final border   = isLight ? const Color(0xFFDDDDDD) : const Color(0xFF242424);
    final textMain = isLight ? Colors.black : Colors.white;
    final textDim  = isLight ? const Color(0xFF888888) : const Color(0xFF555555);
    final accent   = GlobalColors.primaryColor;

    final remaining = kMinTargetSelections - _realSelections;
    final progress =
        (_realSelections / kMinTargetSelections).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App bar ────────────────────────────────────────────────────
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //   child: IconButton(
            //     onPressed: () => Routemaster.of(context).pop(),
            //     icon: Icon(Icons.arrow_back_ios_new_rounded,
            //         size: 18, color: textMain),
            //   ),
            // ),
            
            // ── Hero header ───────────────────────────────────────────────
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: textDim.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Step 2 of 3',
                          style: TextStyle(
                            fontSize: scaler.scale(11),
                            fontWeight: FontWeight.w600,
                            color: textDim,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your ideal\nperson?',
                        style: TextStyle(
                          fontSize: scaler.scale(36),
                          fontWeight: FontWeight.w900,
                          color: textMain,
                          height: 1.05,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rate what you value most in\nyour partner.',
                        style: TextStyle(
                          fontSize: scaler.scale(13.5),
                          color: textDim,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // ── Scrollable body ───────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 2),
                      child: Container(
                        width: 32,
                        height: 3,
                        decoration: BoxDecoration(
                          color: textDim.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
            
                    // ── Category progress bar ────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                      child: Row(
                        children: [
                          Text(
                            '${detailsIndex + 1} of ${_originalList.length}',
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
                                value: (detailsIndex + 1) /
                                    _originalList.length,
                                minHeight: 3,
                                backgroundColor: border,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(textDim),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            
                    // ── Category navigator ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
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
                              enabled:
                                  detailsIndex < _originalList.length - 1,
                              onTap: () => _navigate(1),
                              isLight: isLight,
                            ),
                          ],
                        ),
                      ),
                    ),
            
                    // ── Search bar ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: border),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) =>
                              _onSearchChange(detailsIndex, catKey),
                          style: TextStyle(
                              fontSize: 13, color: textMain),
                          decoration: InputDecoration(
                            hintText: 'Search $catKey…',
                            hintStyle: TextStyle(
                                fontSize: 13, color: textDim),
                            prefixIcon: Icon(Icons.search_rounded,
                                size: 18, color: textDim),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ),
            
                    // ── Grid ─────────────────────────────────────────────
                    Expanded(
                      child: items.isEmpty
                          ? Center(
                              child: Text(
                                'No results found',
                                style: TextStyle(
                                    fontSize: 13, color: textDim),
                              ),
                            )
                          : FadeTransition(
                              opacity: _fadeAnim,
                              child: SlideTransition(
                                position: _slideAnim,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  child: GridView.builder(
                                    physics:
                                        const BouncingScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          _crossAxisCount(context),
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: 2.2,
                                    ),
                                    itemCount: items.length,
                                    itemBuilder: (ctx, i) {
                                      final item = items[i];
                                      final scale = _getScale(item);
                                      final rated = scale > 0;
                                      return _AttributeChip(
                                        label: item['name']
                                                ?.toString() ??
                                            '',
                                        scale: scale,
                                        isRated: rated,
                                        onTap: () => _showScaleDialog(
                                            context, item, isLight),
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
            
                    // ── Footer: counter + submit ──────────────────────────
                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(18, 10, 18, 22),
                      decoration: BoxDecoration(
                        color: bg,
                        border:
                            Border(top: BorderSide(color: border)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Selection progress
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 4,
                                      backgroundColor: border,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        _canSubmit
                                            ? Colors.green.shade400
                                            : accent,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _canSubmit
                                      ? '$_realSelections rated ✓'
                                      : '$_realSelections / $kMinTargetSelections',
                                  style: TextStyle(
                                    fontSize: scaler.scale(11),
                                    fontWeight: FontWeight.w700,
                                    color: _canSubmit
                                        ? Colors.green.shade400
                                        : textDim,
                                  ),
                                ),
                              ],
                            ),
                          ),
            
                          // Submit button
                          AnimatedOpacity(
                            opacity: _canSubmit ? 1.0 : 0.4,
                            duration: const Duration(milliseconds: 200),
                            child: IgnorePointer(
                              ignoring: !_canSubmit,
                              child: ButtonComponent(
                                text: _canSubmit
                                    ? 'Continue →'
                                    : 'Rate $remaining more to continue',
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                                onTap: () async {
                                  await ref
                                      .read(snapshotServiceProviderImpl
                                          .notifier)
                                      .postTargetProfileSnapshots(
                                          _chosenValues);
            
                                  final state = ref
                                      .read(snapshotServiceProviderImpl);
                                  if (state.error != null) {
                                    showSnackBar(
                                        context, state.error!);
                                  } else {
                                    Routemaster.of(context)
                                        .replace('/profile-pictures');
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _crossAxisCount(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1000) return 6;
    if (w >= 700) return 4;
    return 2;
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

class _AttributeChip extends StatelessWidget {
  final String label;
  final double scale;
  final bool isRated;
  final VoidCallback onTap;
  final Color cardBg;
  final Color border;
  final Color textMain;
  final Color textDim;
  final Color accent;

  const _AttributeChip({
    required this.label,
    required this.scale,
    required this.isRated,
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
          color: isRated ? accent.withOpacity(0.08) : cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isRated ? accent : border,
            width: isRated ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isRated ? FontWeight.w700 : FontWeight.w400,
                      color: isRated ? accent : textDim,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isRated) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: scale / 10,
                              minHeight: 3,
                              backgroundColor:
                                  accent.withOpacity(0.15),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(accent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${scale.toInt()}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isRated)
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