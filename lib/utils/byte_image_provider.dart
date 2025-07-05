import 'package:flutter_riverpod/flutter_riverpod.dart';

class ByteImageProvider extends StateNotifier<String>{
  ByteImageProvider() : super('');

  updateState(String newImage) {
    state = newImage;
  }

}

final byteImageProviderImpl =
    StateNotifierProvider<ByteImageProvider, String>(
        (ref) => ByteImageProvider());