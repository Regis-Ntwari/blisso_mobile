import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AudioPlayer extends StatefulWidget {
  final dynamic message;
  const AudioPlayer({super.key, required this.message});

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  FlutterSoundPlayer? _player;
  bool isPlaying = false;
  double sliderValue = 0.0;
  double audioDuration = 0.0;
  StreamSubscription? _playerSubscription;
  bool isLoading = false;

  Future<void> _initialize() async {
    setState(() {
      isLoading = true;
    });
    _player = FlutterSoundPlayer();
    await _player!.openPlayer();
    // Initialize with progress callback
    _player!.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  Future<void> _playAudio() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${appDocDir.path}/audio');

      if (widget.message['content_file'] != null) {
        await _player!.startPlayer(
          fromDataBuffer: base64Decode(widget.message['content_file']!),
          whenFinished: () {
            setState(() {
              isPlaying = false;
              sliderValue = 0;
            });
          },
        );
      } else if (widget.message['content_file_url'] != null &&
          widget.message['content_file_url'].isNotEmpty) {
        final fileName = widget.message['content_file_url']!.split('/').last;
        final filePath = '${audioDir.path}/$fileName';
        final file = File(filePath);

        if (!await audioDir.exists()) {
          await audioDir.create(recursive: true);
        }

        if (await file.exists()) {
          await _player!.startPlayer(
            fromURI: filePath,
            whenFinished: () {
              setState(() {
                isPlaying = false;
                sliderValue = 0;
              });
            },
          );
        } else {
          final response =
              await http.get(Uri.parse(widget.message['content_file_url']!));
          if (response.statusCode == 200) {
            await file.writeAsBytes(response.bodyBytes);
            await _player!.startPlayer(
              fromURI: filePath,
              whenFinished: () {
                setState(() {
                  isPlaying = false;
                  sliderValue = 0;
                });
              },
            );
          } else {
            throw Exception("Failed to download audio");
          }
        }
      }

      setState(() => isPlaying = true);
      setState(() {
        isLoading = false;
      });
      _startListening();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  void _startListening() {
    _playerSubscription?.cancel();
    _playerSubscription = _player!.onProgress!.listen((event) {
      if (mounted) {
        setState(() {
          sliderValue = event.position.inMilliseconds.toDouble();
          audioDuration = event.duration.inMilliseconds.toDouble();
          debugPrint(
              'Position: ${event.position}, Duration: ${event.duration}');
        });
      }
    });
  }

  Future<void> _pauseAudio() async {
    await _player?.pausePlayer();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> _stopAudio() async {
    await _player!.stopPlayer();
    setState(() {
      isPlaying = false;
      sliderValue = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _player!.closePlayer();
    super.dispose();
  }

  String _formatDuration(double milliseconds) {
    Duration duration = Duration(milliseconds: milliseconds.round());
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: isPlaying ? _pauseAudio : _playAudio,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            Expanded(
              child: Slider(
                value: sliderValue,
                activeColor: isLightTheme ? GlobalColors.primaryColor : GlobalColors.whiteColor,
                onChanged: (value) async {
                  setState(() => sliderValue = value);
                  await _player!
                      .seekToPlayer(Duration(milliseconds: value.toInt()));
                },
                min: 0.0,
                max: audioDuration > 0 ? audioDuration : 1.0,
              ),
            ),
            // Add duration text
            Text(_formatDuration(sliderValue)),
          ],
        ),
      ],
    );
  }
}
