import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

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
    if (widget.message['content_file'] != null) {
      await _player!.startPlayer(
          fromDataBuffer: base64Decode(widget.message['content_file']!),
          whenFinished: () {
            setState(() => isPlaying = false);
          });
    } else if (widget.message['content_file_url'] != null ||
        widget.message['content_file_url'] == '') {
      await _player!.startPlayer(
          fromURI: widget.message['content_file_url']!,
          whenFinished: () {
            setState(() => isPlaying = false);
          });
    }
    setState(() => isPlaying = true);

    _playerSubscription = _player?.onProgress!.listen((event) {
      setState(() {
        sliderValue = event.position.inMilliseconds.toDouble();
        audioDuration = event.duration.inMilliseconds.toDouble();
      });
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
    _player!.closePlayer();
    _playerSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: isPlaying ? _pauseAudio : _playAudio,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow)),
        Expanded(
            child: Slider(
          value: sliderValue,
          onChanged: (value) {
            setState(() {
              sliderValue = value;
            });
          },
          onChangeEnd: (value) {
            _player!.seekToPlayer(Duration(milliseconds: value.toInt()));
          },
          min: 0.0,
          max: audioDuration > 0 ? audioDuration : 1.0,
        ))
      ],
    );
  }
}
