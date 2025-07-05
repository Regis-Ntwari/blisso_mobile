import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/location/location_service_provider.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
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
      final response = await profileService.getMyProfile();

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        final myprofile = response.result as Map<String, dynamic>;

        // get the new location
        Position position = await ref
            .watch(locationServiceProviderImpl.notifier)
            .getLatitudeAndLongitude();

        // update the whole profile with new latitude
        myprofile['latitude'] = position.latitude;
        myprofile['longitude'] = position.longitude;

        final res = await profileService
            .updateProfile(TargetProfileModel.fromMapNew(myprofile));


        if (!StatusCodes.codes.contains(res.statusCode)) {
          state = ApiState(isLoading: false, error: res.errorMessage);
        } else {
          state = ApiState(isLoading: false, data: res.result);
        }
      }
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }
}

final updateLocationServiceProviderImpl =
    StateNotifierProvider<UpdateLocationServiceProvider, ApiState>((ref) {
  return UpdateLocationServiceProvider(
      profileService: ProfileService(), ref: ref);
});
