import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/added_snaps_provider.dart';
import 'package:blisso_mobile/services/profile/my_profile_service_provider.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showSnapshotDialog(BuildContext context, WidgetRef ref) async {
  if (ref.read(snapshotServiceProviderImpl).data == null) {
    await ref.read(snapshotServiceProviderImpl.notifier).getLifeSnapshots();
  }

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SnapshotEditorSheet(ref: ref),
  );
}

class _SnapshotEditorSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _SnapshotEditorSheet({required this.ref});

  @override
  ConsumerState<_SnapshotEditorSheet> createState() =>
      _SnapshotEditorSheetState();
}

class _SnapshotEditorSheetState extends ConsumerState<_SnapshotEditorSheet>
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
        .read(addedSnapsProviderImpl.notifier)
        .exists(item['id']);
  }

  void _toggle(Map<String, dynamic> item) {
    final provider = ref.read(addedSnapsProviderImpl.notifier);
    if (_isSelected(item)) {
      provider.removeSnapshot(item['id']);
    } else {
      provider.addSnapshot({
        'lifesnapshot_id': item['id'],
        'name': item['name'],
        'sub_category': item['sub_category'],
        'category': item['category'],
      });
    }
    setState(() {});
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final newSnaps = ref.read(addedSnapsProviderImpl);
    final List<dynamic> filtered = [];
    for (var s in newSnaps) {
      filtered.add(s['lifesnapshot_id']);
    }

    await ref
        .read(snapshotServiceProviderImpl.notifier)
        .editProfileSnapshots(filtered);

    ref.read(myProfileServiceProviderImpl.notifier).addSnapshot(newSnaps);

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
    final selectedCount = ref.watch(addedSnapsProviderImpl).length;

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
                  'Edit My Interests',
                  style: TextStyle(
                    fontSize: scaler.scale(19),
                    fontWeight: FontWeight.w800,
                    color: textMain,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to select or deselect attributes',
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
                            childAspectRatio: 2.7,
                          ),
                          itemCount: items.length,
                          itemBuilder: (ctx, i) {
                            final item = items[i];
                            final selected =
                                _isSelected(item);
                            return _SnapChip(
                              label: item['name']
                                      ?.toString() ??
                                  '',
                              isSelected: selected,
                              onTap: () =>
                                  _toggle(item),
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
                    '$selectedCount selected',
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
                    text: _isSubmitting ? 'Saving…' : 'Save Changes',
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

class _SnapChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color cardBg;
  final Color border;
  final Color textMain;
  final Color textDim;
  final Color accent;

  const _SnapChip({
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
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
