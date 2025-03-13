import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  Future<void> _initialize() async {
    await _player!.openPlayer();
  }

  Future<void> _playAudio() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDocDir.path}/audio');
    if (widget.message['content_file'] != null) {
      await _player!.startPlayer(
          fromDataBuffer: base64Decode(widget.message['content_file']!),
          whenFinished: () {
            setState(() => isPlaying = false);
          });
    } else if (widget.message['content_file_url'] != null ||
        !(widget.message['content_file_url'] == '')) {
      final fileName = widget.message['content_file_url']!.split('/').last;
      final filePath = '${audioDir.path}/$fileName';
      final file = File(filePath);

      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      if (await file.exists()) {
        // Play from local file
        await _player!.startPlayer(
          fromDataBuffer: file.readAsBytesSync(),
          whenFinished: () {
            setState(() => isPlaying = false);
          },
        );
      } else {
        // Download audio and save it
        final response =
            await http.get(Uri.parse(widget.message['content_file_url']!));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          await _player!.startPlayer(
            fromDataBuffer: file.readAsBytesSync(),
            whenFinished: () {
              setState(() => isPlaying = false);
            },
          );
        } else {
          throw Exception("Failed to download audio");
        }
      }
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      _listenAudioProgress();
    });
    setState(() => isPlaying = true);

    // Listen for progress updates
    // _player?.onProgress?.listen((event) {
    //   setState(() {
    //     sliderValue = event.position.inMilliseconds.toDouble();
    //     audioDuration = event.duration.inMilliseconds.toDouble();
    //   });
    // });
  }

  void _listenAudioProgress() {
    debugPrint("Starting to listen for audio progress...");

    _playerSubscription?.cancel();
    _playerSubscription = _player?.dispositionStream()?.listen((event) {
      debugPrint("Progress Event Received!");
      if (mounted) {
        debugPrint("Updating UI...");
        setState(() {
          sliderValue = event.position.inMilliseconds.toDouble();
          audioDuration = event.duration.inMilliseconds.toDouble();
          debugPrint("Slider Value: $sliderValue, Duration: $audioDuration");
        });
      }
    });

    if (_playerSubscription == null) {
      debugPrint("dispositionStream() is not emitting events!");
    }
  }

  Future<void> _pauseAudio() async {
    await _player?.pausePlayer();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> _stopAudio() async {
    await _player!.stopPlayer();
    setState(() => isPlaying = false);
  }

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _playerSubscription?.cancel();
    _player!.closePlayer();
  }

  @override
  Widget build(BuildContext context) {
    print(sliderValue);
    return Row(
      children: [
        IconButton(
            onPressed: isPlaying ? _pauseAudio : _playAudio,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow)),
        Expanded(
            child: Slider(
          value: sliderValue,
          onChanged: (value) {
            setState(() => sliderValue = value);
          },
          onChangeEnd: (value) async {
            await _player!.seekToPlayer(Duration(milliseconds: value.toInt()));
          },
          min: 0.0,
          max: audioDuration > 0 ? audioDuration : 1.0,
        ))
      ],
    );
  }
}
