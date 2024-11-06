import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/location/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationServiceProvider extends StateNotifier<ApiState> {
  final LocationService locationService;

  LocationServiceProvider(this.locationService) : super(ApiState());

  Future<Position> getLatitudeAndLongitude() async {
    late Position position;
    try {
      position = await locationService.determineLocation();

      state = ApiState(data: position, isLoading: false);
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }

    return position;
  }

  Future<String> getAddress(Position position) async {
    late String address;
    try {
      state = ApiState(isLoading: true);

      address = await locationService.getAddress(position);

      state = ApiState(data: address, isLoading: false);
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }

    return address;
  }
}

final locationServiceProviderImpl =
    StateNotifierProvider<LocationServiceProvider, ApiState>((ref) {
  return LocationServiceProvider(LocationService());
});
