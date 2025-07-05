import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/location/location_service_provider.dart';
import 'package:blisso_mobile/services/profile/profile_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class UpdateLocationServiceProvider extends StateNotifier<ApiState> {
  final Ref ref;
  final ProfileService profileService;

  UpdateLocationServiceProvider(
      {required this.profileService, required this.ref})
      : super(ApiState());

  Future<void> updateLocation() async {
    state = ApiState(isLoading: true);

    try {
      Position position = await ref
          .watch(locationServiceProviderImpl.notifier)
          .getLatitudeAndLongitude();

      final response = await profileService.changeLocation(
          {'latitude': position.latitude, 'longitude': position.longitude});

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        
      }
      
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }
}

final updateLocationServiceProviderImpl =
    StateNotifierProvider<UpdateLocationServiceProvider, ApiState>((ref) {
  return UpdateLocationServiceProvider(
      profileService: ProfileService(), ref: ref);
});
