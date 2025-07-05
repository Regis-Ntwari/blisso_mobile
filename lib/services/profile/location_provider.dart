import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationProvider extends StateNotifier<bool>{
  LocationProvider() : super(true);

  updateState() {
    state = !state;
  }

}

final locationProviderImpl =
    StateNotifierProvider<LocationProvider, bool>(
        (ref) => LocationProvider());