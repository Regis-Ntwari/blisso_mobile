import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/added_target_snaps_provider.dart';
import 'package:blisso_mobile/services/profile/my_profile_service_provider.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showTargetSnapshotDialog(BuildContext context, WidgetRef ref) async {
  if (ref.read(snapshotServiceProviderImpl).data == null) {
    await ref.read(snapshotServiceProviderImpl.notifier).getLifeSnapshots();
  }

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TargetSnapshotEditorSheet(ref: ref),
  );
}

class _TargetSnapshotEditorSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _TargetSnapshotEditorSheet({required this.ref});

  @override
  ConsumerState<_TargetSnapshotEditorSheet> createState() =>
      _TargetSnapshotEditorSheetState();
}

class _TargetSnapshotEditorSheetState
    extends ConsumerState<_TargetSnapshotEditorSheet>
    with SingleTickerProviderStateMixin {
  int _categoryIndex = 0;
  late List<Map<String, List<Map<String, dynamic>>>> _grouped;
  late List<Map<String, List<Map<String, dynamic>>>> _original;
  late TextEditingController _searchCtrl;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();

    _buildGroupedData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _buildGroupedData() {
    final snapshots = ref.read(snapshotServiceProviderImpl).data ?? [];
    final List<Map<String, List<Map<String, dynamic>>>> result = [];

    for (final item in snapshots) {
      final sub = item['sub_category'] as String? ?? 'Other';
      final existing = result.firstWhere(
        (e) => e.containsKey(sub),
        orElse: () => {},
      );
      if (existing.isNotEmpty) {
        existing[sub]!.add(Map<String, dynamic>.from(item));
      } else {
        result.add({
          sub: [Map<String, dynamic>.from(item)]
        });
      }
    }

    _original = result;
    _grouped = result
        .map((e) => Map<String, List<Map<String, dynamic>>>.from(e))
        .toList();
  }

  void _navigate(int dir) {
    final next = _categoryIndex + dir;
    if (next >= 0 && next < _original.length) {
      setState(() {
        _categoryIndex = next;
        _searchCtrl.clear();
        _grouped = _original
            .map((e) => Map<String, List<Map<String, dynamic>>>.from(e))
            .toList();
      });
      _animCtrl.forward(from: 0);
    }
  }

  void _onSearch(String catKey) {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _grouped[_categoryIndex][catKey] = _original[_categoryIndex][catKey]!
          .where((e) =>
              (e['name'] ?? '').toString().toLowerCase().contains(query))
          .toList();
    });
  }

  bool _isSelected(Map<String, dynamic> item) {
    return ref
        .read(addedTargetSnapsProviderImpl.notifier)
        .exists(item['id']);
  }

  int _getScale(Map<String, dynamic> item) {
    final snaps = ref.read(addedTargetSnapsProviderImpl);
    for (var s in snaps) {
      if (s['lifesnapshot_id'] == item['id']) {
        return (s['target_scale'] as num?)?.toInt() ?? 0;
      }
    }
    return 0;
  }

  void _showScaleDialog(
      BuildContext context, Map<String, dynamic> item, bool isLight) {
    final bg = isLight ? Colors.white : Colors.black;
    final textMain = isLight ? Colors.black : Colors.white;
    final textDim =
        isLight ? const Color(0xFF888888) : const Color(0xFF555555);
    final border =
        isLight ? const Color(0xFFDDDDDD) : const Color(0xFF242424);
    final accent = GlobalColors.primaryColor;

    int currentScale = _getScale(item);
    if (currentScale == 0) currentScale = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Dialog(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item['name'] ?? '',
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
                  style:
                      TextStyle(fontSize: 12.5, color: textDim),
                ),
                const SizedBox(height: 24),

                // Scale badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: accent),
                  ),
                  child: Text(
                    _scaleLabel(currentScale),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accent,
                    inactiveTrackColor: border,
                    thumbColor: accent,
                    overlayColor: accent.withOpacity(0.12),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: currentScale.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: currentScale.toString(),
                    onChanged: (v) {
                      setDlg(() => currentScale = v.toInt());
                    },
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1',
                          style: TextStyle(
                              fontSize: 11, color: textDim)),
                      Text('10',
                          style: TextStyle(
                              fontSize: 11, color: textDim)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ButtonComponent(
                    text: 'Confirm',
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    onTap: () {
                      ref
                          .read(addedTargetSnapsProviderImpl
                              .notifier)
                          .addSnapshot({
                        'lifesnapshot_id': item['id'],
                        'name': item['name'],
                        'sub_category': item['sub_category'],
                        'category': item['category'],
                        'target_scale': currentScale,
                      });
                      setState(() {});
                      Navigator.of(ctx).pop();
                    },
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

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final newSnaps = ref.read(addedTargetSnapsProviderImpl);
    final List<dynamic> filtered = [];
    for (var s in newSnaps) {
      filtered.add({
        'id': s['lifesnapshot_id'],
        'scale': s['target_scale'],
      });
    }

    await ref
        .read(snapshotServiceProviderImpl.notifier)
        .addTargetSnapshot(filtered);

    ref
        .read(myProfileServiceProviderImpl.notifier)
        .addTargetSnapshot(newSnaps);

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final scaler = MediaQuery.textScalerOf(context);

    final bg = isLight ? Colors.white : Colors.black;
    final cardBg =
        isLight ? const Color(0xFFF2F2F2) : const Color(0xFF0E0E0E);
    final border =
        isLight ? const Color(0xFFDDDDDD) : const Color(0xFF242424);
    final textMain = isLight ? Colors.black : Colors.white;
    final textDim =
        isLight ? const Color(0xFF888888) : const Color(0xFF555555);
    final accent = GlobalColors.primaryColor;

    if (_grouped.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final catKey = _grouped[_categoryIndex].keys.first;
    final items = _grouped[_categoryIndex][catKey] ?? [];
    final selectedCount = ref
        .watch(addedTargetSnapsProviderImpl)
        .where((s) => (s['target_scale'] ?? 0) > 0)
        .length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: textDim.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 2),
            child: Column(
              children: [
                Text(
                  'Edit Interests in a Person',
                  style: TextStyle(
                    fontSize: scaler.scale(19),
                    fontWeight: FontWeight.w800,
                    color: textMain,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to rate how important each is to you',
                  style: TextStyle(
                    fontSize: scaler.scale(12),
                    color: textDim,
                  ),
                ),
              ],
            ),
          ),

          // Category progress
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
            child: Row(
              children: [
                Text(
                  '${_categoryIndex + 1} of ${_original.length}',
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
                      value:
                          (_categoryIndex + 1) / _original.length,
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

          // Category navigator
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
                    enabled: _categoryIndex > 0,
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
                        _categoryIndex < _original.length - 1,
                    onTap: () => _navigate(1),
                    isLight: isLight,
                  ),
                ],
              ),
            ),
          ),

          // Search bar
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
                onChanged: (_) => _onSearch(catKey),
                style: TextStyle(fontSize: 13, color: textMain),
                decoration: InputDecoration(
                  hintText: 'Search $catKey…',
                  hintStyle:
                      TextStyle(fontSize: 13, color: textDim),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 18, color: textDim),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),

          // Grid
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text('No results found',
                        style:
                            TextStyle(fontSize: 13, color: textDim)),
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
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: items.length,
                          itemBuilder: (ctx, i) {
                            final item = items[i];
                            final selected =
                                _isSelected(item);
                            final scale =
                                _getScale(item).toDouble();
                            return _AttributeChip(
                              label: item['name']
                                      ?.toString() ??
                                  '',
                              scale: scale,
                              isRated: selected &&
                                  scale > 0,
                              onTap: () {
                                if (selected) {
                                  ref
                                      .read(
                                          addedTargetSnapsProviderImpl
                                              .notifier)
                                      .removeSnapshot(
                                          item['id']);
                                  setState(() {});
                                } else {
                                  _showScaleDialog(
                                      context,
                                      item,
                                      isLight);
                                }
                              },
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

          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
            decoration: BoxDecoration(
              color: bg,
              border: Border(top: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$selectedCount rated',
                    style: TextStyle(
                      fontSize: scaler.scale(12),
                      fontWeight: FontWeight.w600,
                      color: textDim,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ButtonComponent(
                    text:
                        _isSubmitting ? 'Saving…' : 'Save Changes',
                    backgroundColor:
                        _isSubmitting ? textDim : accent,
                    foregroundColor: Colors.white,
                    onTap: _isSubmitting ? () {} : _submit,
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isRated
                          ? FontWeight.w700
                          : FontWeight.w400,
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
                            borderRadius:
                                BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: scale / 10,
                              minHeight: 3,
                              backgroundColor:
                                  accent.withOpacity(0.15),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      accent),
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
