import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;

class AudioPlayerScreen extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerScreen({super.key, required this.audioUrl});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _player.openPlayer().then((value) {
      _progressSubscription = _player.onProgress?.listen((e) {
        setState(() {
          _position = e.position;
          _duration = e.duration;
        });
      });
    });
  }

  Future<void> _play() async {
    try {
      final response = await http.get(Uri.parse(widget.audioUrl));
      if (response.statusCode == 200) {
        await _player.startPlayer(
            fromDataBuffer: response.bodyBytes, codec: Codec.aacADTS);
        setState(() => _isPlaying = true);
        _progressSubscription = _player.onProgress?.listen((e) {
          setState(() {
            _position = e.position;
            _duration = e.duration;
            if (e.duration.inMilliseconds == e.position.inMilliseconds) {
              setState(() => _isPlaying = false);
            }
          });
        });
      } else {
        throw Exception("Failed to load audio");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _stop() async {
    await _player.stopPlayer();
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              onPressed: _isPlaying ? _stop : _play,
            ),
            Slider(
              min: 0,
              max: _duration.inMilliseconds.toDouble(),
              value: _position.inMilliseconds.toDouble(),
              onChanged: (value) {},
            ),
            Text("${_position.inSeconds} / ${_duration.inSeconds} seconds")
          ],
        ),
      ),
    ));
  }
}
