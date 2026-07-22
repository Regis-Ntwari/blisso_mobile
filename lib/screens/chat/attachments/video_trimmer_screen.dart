import 'dart:io';

import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

/// Minimum selectable clip length in seconds.
const int _kMinTrimSeconds = 1;

class VideoTrimmerScreen extends StatefulWidget {
  final File videoFile;
  final String title;

  const VideoTrimmerScreen({
    super.key,
    required this.videoFile,
    this.title = 'Trim Video',
  });

  @override
  State<VideoTrimmerScreen> createState() => _VideoTrimmerScreenState();
}

class _VideoTrimmerScreenState extends State<VideoTrimmerScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isTrimming = false;
  double _trimProgress = 0;

  double _startMs = 0.0;
  double _endMs = 0.0;
  double _totalMs = 1.0;

  Duration _totalDuration = Duration.zero;
  Duration _playheadPosition = Duration.zero;
  bool _isPlaying = false;
  bool _isDisposing = false;

  late final Subscription _compressSubscription;

  @override
  void initState() {
    super.initState();
    _compressSubscription =
        VideoCompress.compressProgress$.subscribe((progress) {
      if (mounted && _isTrimming) {
        setState(() => _trimProgress = progress);
      }
    });
    _initController();
  }

  // ── Controller ─────────────────────────────────────────────────────────────

  Future<void> _initController() async {
    await _disposeController();
    if (!mounted) return;

    final ctrl = VideoPlayerController.file(widget.videoFile);
    try {
      await ctrl.initialize();
    } catch (e) {
      debugPrint('VideoTrimmer: init failed — $e');
      await ctrl.dispose();
      if (mounted) _showSnack('Failed to load video. Please try again.');
      return;
    }

    if (!mounted) {
      await ctrl.dispose();
      return;
    }

    final totalMs =
        ctrl.value.duration.inMilliseconds.toDouble().clamp(1.0, double.infinity);

    _controller = ctrl;
    setState(() {
      _totalDuration = ctrl.value.duration;
      _totalMs = totalMs;
      _startMs = 0.0;
      _endMs = totalMs;
      _isInitialized = true;
    });

    ctrl.addListener(_onVideoUpdate);
  }

  Future<void> _disposeController() async {
    final ctrl = _controller;
    if (ctrl == null) return;
    _controller = null; // null immediately so listener checks fail-fast
    ctrl.removeListener(_onVideoUpdate);
    try {
      await ctrl.pause();
    } catch (_) {}
    try {
      await ctrl.dispose();
    } catch (_) {}
  }

  void _onVideoUpdate() {
    final ctrl = _controller;
    if (ctrl == null || !mounted || _isDisposing) return;

    final val = ctrl.value;
    final pos = val.position;
    final playing = val.isPlaying;

    // Loop within the selected window.
    if (playing && pos.inMilliseconds >= _endMs) {
      ctrl.pause();
      ctrl.seekTo(_startDuration);
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playheadPosition = _startDuration;
        });
      }
      return;
    }

    final posChanged =
        (pos - _playheadPosition).abs() >= const Duration(milliseconds: 80);
    final playingChanged = playing != _isPlaying;

    if (posChanged || playingChanged) {
      setState(() {
        _playheadPosition = pos;
        _isPlaying = playing;
      });
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Duration get _startDuration => Duration(milliseconds: _startMs.round());
  Duration get _endDuration => Duration(milliseconds: _endMs.round());
  Duration get _selectedDuration => _endDuration - _startDuration;

  double get _playheadFraction =>
      (_playheadPosition.inMilliseconds / _totalMs).clamp(0.0, 1.0);
  double get _startFraction => (_startMs / _totalMs).clamp(0.0, 1.0);
  double get _endFraction => (_endMs / _totalMs).clamp(0.0, 1.0);
  double get _minGapMs => (_kMinTrimSeconds * 1000).toDouble();

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms =
        (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$m:$s.$ms';
  }

  // ── Playback ───────────────────────────────────────────────────────────────

  void _togglePlayback() {
    final ctrl = _controller;
    if (ctrl == null || !_isInitialized || _isTrimming) return;
    if (ctrl.value.isPlaying) {
      ctrl.pause();
    } else {
      if (_playheadPosition >= _endDuration ||
          _playheadPosition < _startDuration) {
        ctrl.seekTo(_startDuration);
      }
      ctrl.play();
    }
  }

  // ── Trim ───────────────────────────────────────────────────────────────────

  Future<void> _trimAndReturn() async {
    // ── 1. Validate ───────────────────────────────────────────────────────
    final selectedMs = (_endMs - _startMs).round(); // exact ms span
    if (selectedMs < _kMinTrimSeconds * 1000) {
      _showSnack('Please select at least $_kMinTrimSeconds second(s).');
      return;
    }

    setState(() {
      _isTrimming = true;
      _trimProgress = 0;
    });

    // ── 2. Snapshot trim points precisely before disposing the controller ─
    //
    // VideoCompress.compressVideo() only accepts whole-second integers for
    // startTime and duration. To avoid losing content at the edges we:
    //   • floor the start second  (start no later than the user's mark)
    //   • ceil  the duration in seconds (end no earlier than the user's mark)
    //
    // This means the output may contain up to ~1 s of extra content at the
    // very start, but the user's intended clip is always fully included.
    // This is the best precision available with VideoCompress on this API.
    final startSec = (_startMs / 1000).floor();
    final endSec   = (_endMs   / 1000).ceil();
    final durationSec = (endSec - startSec)
        .clamp(_kMinTrimSeconds, _totalDuration.inSeconds - startSec);

    debugPrint(
        'VideoTrimmer: trimming — '
        'startMs=${_startMs.round()} endMs=${_endMs.round()} '
        '=> startSec=$startSec durationSec=$durationSec');

    // ── 3. Release file handle (critical on Android) ──────────────────────
    await _disposeController();
    if (!mounted) return;

    // ── 4. Compress / trim ────────────────────────────────────────────────
    try {
      final result = await VideoCompress.compressVideo(
        widget.videoFile.path,
        quality: VideoQuality.DefaultQuality,
        startTime: startSec,
        duration: durationSec,
        includeAudio: true,
        deleteOrigin: false,
      );

      if (!mounted) return;

      final outFile = result?.file;
      if (outFile != null && await outFile.exists()) {
        // Copy to a stable temp path before VideoCompress deletes its scratch.
        final tempDir =
            await Directory.systemTemp.createTemp('blisso_trim_');
        if (!mounted) return;

        final stablePath =
            '${tempDir.path}/trimmed_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final stableFile = await outFile.copy(stablePath);
        if (!mounted) return;

        debugPrint(
            'VideoTrimmer: done — ${stableFile.path} '
            '(${(stableFile.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB)');

        Navigator.of(context).pop(stableFile);
      } else {
        if (!mounted) return;
        _showSnack('Trim produced no output. Please try again.');
        setState(() {
          _isTrimming = false;
          _trimProgress = 0;
        });
        await _initController();
      }
    } catch (e, st) {
      debugPrint('VideoTrimmer: error — $e\n$st');
      if (!mounted) return;
      _showSnack('Error trimming video: $e');
      setState(() {
        _isTrimming = false;
        _trimProgress = 0;
      });
      await _initController();
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: GlobalColors.primaryColor,
      ));
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _isDisposing = true;
    _compressSubscription.unsubscribe();
    VideoCompress.cancelCompression();
    _disposeController(); // fire-and-forget; _isDisposing guards callbacks
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          if (!_isTrimming)
            TextButton(
              onPressed: () => Navigator.of(context).pop(widget.videoFile),
              child: const Text('Skip',
                  style: TextStyle(color: Colors.white70, fontSize: 15)),
            ),
        ],
      ),
      body: !_isInitialized
          ? const Center(
              child: CircularProgressIndicator(
                  color: GlobalColors.primaryColor))
          : Column(
              children: [
                _VideoPreview(
                  controller: _controller!,
                  isTrimming: _isTrimming,
                  onTap: _togglePlayback,
                  isPlaying: _isPlaying,
                ),
                Container(
                  color: const Color(0xFF0F0F0F),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TimeLabelRow(
                        startDuration: _startDuration,
                        endDuration: _endDuration,
                        selectedDuration: _selectedDuration,
                        fmt: _fmt,
                      ),
                      const SizedBox(height: 10),
                      _TrimBar(
                        startFraction: _startFraction,
                        endFraction: _endFraction,
                        playheadFraction: _playheadFraction,
                        totalMs: _totalMs,
                        minGapMs: _minGapMs,
                        isTrimming: _isTrimming,
                        onStartChanged: (ms) => setState(() =>
                            _startMs = ms.clamp(0.0, _endMs - _minGapMs)),
                        onEndChanged: (ms) => setState(() =>
                            _endMs = ms.clamp(_startMs + _minGapMs, _totalMs)),
                        onDragEnd: () {
                          final ctrl = _controller;
                          if (ctrl != null) {
                            ctrl.pause();
                            ctrl.seekTo(_startDuration);
                          }
                        },
                        primaryColor: GlobalColors.primaryColor,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Total: ${_fmt(_totalDuration)}',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                      const SizedBox(height: 14),
                      IconButton(
                        onPressed: _isTrimming ? null : _togglePlayback,
                        icon: Icon(
                          _isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color:
                              _isTrimming ? Colors.grey[700] : Colors.white,
                          size: 52,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isTrimming ? null : _trimAndReturn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GlobalColors.primaryColor,
                            disabledBackgroundColor:
                                GlobalColors.primaryColor.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: _isTrimming
                              ? _TrimProgressIndicator(
                                  progress: _trimProgress)
                              : const Text(
                                  'Trim & Continue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _VideoPreview extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isTrimming;
  final VoidCallback onTap;
  final bool isPlaying;

  const _VideoPreview({
    required this.controller,
    required this.isTrimming,
    required this.onTap,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: isTrimming ? null : onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            if (!isPlaying && !isTrimming)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 38),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimeLabelRow extends StatelessWidget {
  final Duration startDuration;
  final Duration endDuration;
  final Duration selectedDuration;
  final String Function(Duration) fmt;

  const _TimeLabelRow({
    required this.startDuration,
    required this.endDuration,
    required this.selectedDuration,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(fmt(startDuration),
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFeatures: [FontFeature.tabularFigures()])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: GlobalColors.primaryColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: GlobalColors.primaryColor.withOpacity(0.4), width: 1),
          ),
          child: Text(
            '✂  ${fmt(selectedDuration)}',
            style: const TextStyle(
              color: GlobalColors.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(fmt(endDuration),
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFeatures: [FontFeature.tabularFigures()])),
      ],
    );
  }
}

class _TrimBar extends StatelessWidget {
  final double startFraction;
  final double endFraction;
  final double playheadFraction;
  final double totalMs;
  final double minGapMs;
  final bool isTrimming;
  final ValueChanged<double> onStartChanged;
  final ValueChanged<double> onEndChanged;
  final VoidCallback onDragEnd;
  final Color primaryColor;

  const _TrimBar({
    required this.startFraction,
    required this.endFraction,
    required this.playheadFraction,
    required this.totalMs,
    required this.minGapMs,
    required this.isTrimming,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onDragEnd,
    required this.primaryColor,
  });

  static const double _barHeight = 48.0;
  static const double _thumbWidth = 22.0;
  static const double _thumbHitSlop = 14.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _barHeight + 16,
      child: LayoutBuilder(builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;

        final startX = startFraction * trackWidth;
        final endX = endFraction * trackWidth;
        final phX = playheadFraction * trackWidth;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Background track
            Positioned.fill(
              top: 8,
              bottom: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

            // Dimmed: before start
            if (startX > 0)
              Positioned(
                left: 0,
                top: 8,
                bottom: 8,
                width: startX,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(6)),
                  ),
                ),
              ),

            // Dimmed: after end
            if (endX < trackWidth)
              Positioned(
                left: endX,
                top: 8,
                bottom: 8,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(6)),
                  ),
                ),
              ),

            // Selected region
            Positioned(
              left: startX,
              top: 8,
              bottom: 8,
              width: (endX - startX).clamp(0.0, trackWidth),
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  border: Border(
                    top: BorderSide(color: primaryColor, width: 2),
                    bottom: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
            ),

            // Playhead
            Positioned(
              left: (phX - 1.25).clamp(0.0, trackWidth - 2.5),
              top: 4,
              bottom: 4,
              child: IgnorePointer(
                child: Container(
                  width: 2.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white.withOpacity(0.6),
                          blurRadius: 4)
                    ],
                  ),
                ),
              ),
            ),

            // Start thumb
            Positioned(
              left: (startX - _thumbWidth / 2 - _thumbHitSlop)
                  .clamp(0.0, trackWidth),
              top: 0,
              bottom: 0,
              width: _thumbWidth + _thumbHitSlop * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: isTrimming ? null : (_) {},
                onHorizontalDragUpdate: isTrimming
                    ? null
                    : (d) {
                        final dx = d.primaryDelta ?? 0;
                        final newFrac =
                            (startFraction + dx / trackWidth).clamp(
                                0.0, endFraction - minGapMs / totalMs);
                        onStartChanged(newFrac * totalMs);
                      },
                onHorizontalDragEnd:
                    isTrimming ? null : (_) => onDragEnd(),
                child: Center(
                  child: _Thumb(
                      color: primaryColor,
                      isLeft: true,
                      width: _thumbWidth,
                      height: _barHeight),
                ),
              ),
            ),

            // End thumb
            Positioned(
              left: (endX - _thumbWidth / 2 - _thumbHitSlop)
                  .clamp(0.0, trackWidth),
              top: 0,
              bottom: 0,
              width: _thumbWidth + _thumbHitSlop * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: isTrimming ? null : (_) {},
                onHorizontalDragUpdate: isTrimming
                    ? null
                    : (d) {
                        final dx = d.primaryDelta ?? 0;
                        final newFrac =
                            (endFraction + dx / trackWidth).clamp(
                                startFraction + minGapMs / totalMs, 1.0);
                        onEndChanged(newFrac * totalMs);
                      },
                onHorizontalDragEnd:
                    isTrimming ? null : (_) => onDragEnd(),
                child: Center(
                  child: _Thumb(
                      color: primaryColor,
                      isLeft: false,
                      width: _thumbWidth,
                      height: _barHeight),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Thumb extends StatelessWidget {
  final Color color;
  final bool isLeft;
  final double width;
  final double height;

  const _Thumb({
    required this.color,
    required this.isLeft,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(6) : Radius.zero,
          right: isLeft ? Radius.zero : const Radius.circular(6),
        ),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.5), blurRadius: 6, spreadRadius: 1)
        ],
      ),
      child: Icon(
        isLeft ? Icons.chevron_left : Icons.chevron_right,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}

class _TrimProgressIndicator extends StatelessWidget {
  final double progress;
  const _TrimProgressIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = progress.clamp(0.0, 100.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            value: pct > 0 ? pct / 100 : null,
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          pct > 0 ? 'Trimming… ${pct.toStringAsFixed(0)}%' : 'Trimming…',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}