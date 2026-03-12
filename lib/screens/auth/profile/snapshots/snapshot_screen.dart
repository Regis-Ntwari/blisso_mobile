import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/auth/profile/snapshots/profile_snapshots_component.dart';
import 'package:blisso_mobile/services/snapshots/my_snapshots_provider.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class SnapshotScreen extends ConsumerStatefulWidget {
  const SnapshotScreen({super.key});

  @override
  ConsumerState<SnapshotScreen> createState() => _SnapshotScreenState();
}

class _SnapshotScreenState extends ConsumerState<SnapshotScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;

  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerFade = CurvedAnimation(
      parent: _headerCtrl,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    await ref.read(snapshotServiceProviderImpl.notifier).getLifeSnapshots();
    if (mounted) setState(() => isLoading = false);
  }

  List<Map<String, List<Map<String, dynamic>>>> _buildList(List<dynamic> data) {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(snapshotServiceProviderImpl);
    final chosenValues = ref.watch(mySnapshotsProviderImpl);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final scaler = MediaQuery.textScalerOf(context);

    // Pure black / white backgrounds
    final bg      = isLight ? Colors.white : Colors.black;
    final textMain = isLight ? Colors.black : Colors.white;
    final textDim  = isLight ? const Color(0xFF888888) : const Color(0xFF555555);

    final showLoading =
        (state.isLoading && isLoading) || state.data == null;

    return SafeArea(
      child: Scaffold(
        backgroundColor: bg,
        body: showLoading
            ? const LoadingScreen()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── App bar ──────────────────────────────────────────────
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //   child: IconButton(
                  //     onPressed: () => Routemaster.of(context).pop(),
                  //     icon: Icon(
                  //       Icons.arrow_back_ios_new_rounded,
                  //       size: 18,
                  //       color: textMain,
                  //     ),
                  //   ),
                  // ),

                  // ── Hero text ────────────────────────────────────────────
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: textDim.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Step 1 of 3',
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
                              'Who are\nyou?',
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
                              'Pick the traits that define your\nlifestyle and personality.',
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

                  // ── Component fills remaining space ──────────────────────
                  Expanded(
                    child: ProfileSnapshotsComponent(
                      values: state.data != null ? _buildList(state.data!) : [],
                      chosenValues: chosenValues,
                      checkInterest: ref
                          .read(mySnapshotsProviderImpl.notifier)
                          .containsInterest,
                      toggleInterest: ref
                          .read(mySnapshotsProviderImpl.notifier)
                          .toggleInterest,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}