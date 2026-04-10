import 'dart:io';

import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:routemaster/routemaster.dart';

class ProfilePicturesComponent extends ConsumerStatefulWidget {
  const ProfilePicturesComponent({super.key});

  @override
  ConsumerState<ProfilePicturesComponent> createState() =>
      _ProfilePicturesComponentState();
}

class _ProfilePicturesComponentState
    extends ConsumerState<ProfilePicturesComponent>
    with SingleTickerProviderStateMixin {
  final List<File?> _pictures = [null, null, null, null];
  final ImagePicker _picker = ImagePicker();

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
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, int index) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() => _pictures[index] = File(picked.path));
    }
  }

  void _showPickerSheet(BuildContext context, int index, bool isLight) {
    final bg       = isLight ? Colors.white : Colors.black;
    final textMain = isLight ? Colors.black : Colors.white;
    final textDim  = isLight ? const Color(0xFF888888) : const Color(0xFF555555);
    final border   = isLight ? const Color(0xFFDDDDDD) : const Color(0xFF242424);

    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: textDim.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _pictures[index] != null ? 'Replace photo' : 'Add a photo',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textMain,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              _SheetOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from Gallery',
                bg: bg,
                border: border,
                textMain: textMain,
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery, index);
                },
              ),
              const SizedBox(height: 10),
              _SheetOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take a Photo',
                bg: bg,
                border: border,
                textMain: textMain,
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera, index);
                },
              ),
              if (_pictures[index] != null) ...[
                const SizedBox(height: 10),
                _SheetOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove photo',
                  bg: bg,
                  border: border,
                  textMain: Colors.red.shade400,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _pictures[index] = null);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  int get _filledCount => _pictures.where((p) => p != null).length;
  bool get _canSubmit => _filledCount == 4;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(snapshotServiceProviderImpl);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final scaler = MediaQuery.textScalerOf(context);

    final bg       = isLight ? Colors.white : Colors.black;
    final textMain = isLight ? Colors.black : Colors.white;
    final textDim  = isLight ? const Color(0xFF888888) : const Color(0xFF555555);
    final border   = isLight ? const Color(0xFFDDDDDD) : const Color(0xFF242424);
    final cardBg   = isLight ? const Color(0xFFF2F2F2) : const Color(0xFF0E0E0E);
    final accent   = GlobalColors.primaryColor;

    return SafeArea(
      child: Scaffold(
        backgroundColor: bg,
        body: snapshot.isLoading
            ? const LoadingScreen()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── App bar ──────────────────────────────────────────────
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 8, vertical: 4),
                  //   child: IconButton(
                  //     onPressed: () => Routemaster.of(context).pop(),
                  //     icon: Icon(Icons.arrow_back_ios_new_rounded,
                  //         size: 18, color: textMain),
                  //   ),
                  // ),

                  // ── Hero header ──────────────────────────────────────────
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(24, 0, 24, 20),
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
                                'Step 3 of 3',
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
                              'Show your\nbest self.',
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
                              'Add 4 photos that represent\nwho you really are.',
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

                  // ── Photo grid ───────────────────────────────────────────
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                      ),
                      child: Column(
                        children: [
                          // Drag handle
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10, bottom: 14),
                            child: Container(
                              width: 32,
                              height: 3,
                              decoration: BoxDecoration(
                                color: textDim.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 0.82,
                                ),
                                itemCount: 4,
                                itemBuilder: (ctx, i) => _PhotoSlot(
                                  index: i,
                                  file: _pictures[i],
                                  cardBg: cardBg,
                                  border: border,
                                  textDim: textDim,
                                  accent: accent,
                                  onTap: () =>
                                      _showPickerSheet(context, i, isLight),
                                ),
                              ),
                            ),
                          ),

                          // ── Footer ──────────────────────────────────────
                          Container(
                            padding:
                                const EdgeInsets.fromLTRB(18, 10, 18, 22),
                            decoration: BoxDecoration(
                              color: bg,
                              border: Border(
                                  top: BorderSide(color: border)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Photo count progress
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          child: LinearProgressIndicator(
                                            value: _filledCount / 4,
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
                                            ? '4 / 4  ✓'
                                            : '$_filledCount / 4',
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
                                  duration:
                                      const Duration(milliseconds: 200),
                                  child: IgnorePointer(
                                    ignoring: !_canSubmit,
                                    child: ButtonComponent(
                                      text: _canSubmit
                                          ? 'Finish Setup →'
                                          : 'Add ${4 - _filledCount} more photo${(4 - _filledCount) == 1 ? '' : 's'}',
                                      backgroundColor: accent,
                                      foregroundColor: Colors.white,
                                      onTap: () async {
                                        await ref
                                            .read(snapshotServiceProviderImpl
                                                .notifier)
                                            .postProfileImages([
                                          _pictures[0]!,
                                          _pictures[1]!,
                                          _pictures[2]!,
                                          _pictures[3]!,
                                        ]);

                                        final state = ref.read(
                                            snapshotServiceProviderImpl);
                                        if (state.error != null) {
                                          showSnackBar(
                                              context, state.error!);
                                        } else {
                                          Routemaster.of(context)
                                              .push('/homepage');
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
}

// ─────────────────────────────────────────────────────────────────────────────

class _PhotoSlot extends StatelessWidget {
  final int index;
  final File? file;
  final Color cardBg;
  final Color border;
  final Color textDim;
  final Color accent;
  final VoidCallback onTap;

  static const List<String> _hints = [
    'Main photo',
    'Show a smile',
    'Your favourite place',
    'Doing what you love',
  ];

  const _PhotoSlot({
    required this.index,
    required this.file,
    required this.cardBg,
    required this.border,
    required this.textDim,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = file != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasPhoto ? accent : border,
            width: hasPhoto ? 1.8 : 1.2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo or placeholder
              if (hasPhoto)
                Image.file(file!, fit: BoxFit.cover)
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 22,
                        color: accent.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hints[index],
                      style: TextStyle(
                        fontSize: 11,
                        color: textDim,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

              // Subtle dark scrim on photos so the badge reads well
              if (hasPhoto)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.35),
                      ],
                      stops: const [0.55, 1.0],
                    ),
                  ),
                ),

              // Slot number badge (top-left)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: hasPhoto
                        ? accent
                        : textDim.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: hasPhoto
                        ? const Icon(Icons.check_rounded,
                            size: 13, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: textDim,
                            ),
                          ),
                  ),
                ),
              ),

              // Edit icon overlay (bottom-right) when photo exists
              if (hasPhoto)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        size: 13, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color border;
  final Color textMain;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.bg,
    required this.border,
    required this.textMain,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: textMain),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}