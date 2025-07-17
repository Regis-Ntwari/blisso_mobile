import 'dart:io';

import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnapshotServiceProvider extends StateNotifier<ApiState> {
  final SnapshotService snapshotService;
  final Ref ref;

  SnapshotServiceProvider({required this.snapshotService, required this.ref}) : super(ApiState());

  Future<void> getLifeSnapshots() async {
    try {
      state = ApiState(isLoading: true);

      final snapshots = await snapshotService.fetchProfileSnapshots();

      if (!StatusCodes.codes.contains(snapshots.statusCode)) {
        state = ApiState(error: snapshots.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: snapshots.result, isLoading: false);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> postMyProfileSnapshots(List<int> snapshots) async {
    try {
      state = ApiState(isLoading: true);

      final response = await snapshotService.postProfileSnapshots(snapshots);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);

        SharedPreferencesService.setPreference('is_my_snapshots', true);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> editProfileSnapshots(List<dynamic> snaps) async{
    try {
      state = ApiState(isLoading: true);

      final response = await snapshotService.editSnapshots(snaps);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        //state = ApiState(error: response.errorMessage, isLoading: false);
        state = ApiState(isLoading: false, data: state.data, statusCode: 200);
      } else {
        //state = ApiState(data: response.result, isLoading: false);
        await ref.read(profileServiceProviderImpl.notifier).getMyProfile();

        //SharedPreferencesService.setPreference('is_my_snapshots', true);
        state = ApiState(isLoading: false, data: state.data, statusCode: 200);
      }

    } catch (e) {
      state = ApiState(isLoading: false, data: state.data, statusCode: 200);
    }
  }

  Future<void> deleteProfileSnapshot(int id) async{
    try {
      state = ApiState(isLoading: true);

      final response = await snapshotService.deleteSnapshot(id);
      print(response);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        //state = ApiState(error: response.errorMessage, isLoading: false);
        state = ApiState(isLoading: false, data: state.data, statusCode: 200);
      } else {
        //state = ApiState(data: response.result, isLoading: false);

        await ref.read(profileServiceProviderImpl.notifier).getMyProfile();

        //SharedPreferencesService.setPreference('is_my_snapshots', true);
        state = ApiState(isLoading: false, data: state.data, statusCode: 200);
      }

    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      state = ApiState(isLoading: false, data: state.data, statusCode: 200);
      state = ApiState(isLoading: false);
    }
  }

  Future<void> postTargetProfileSnapshots(List<dynamic> snapshots) async {
    snapshots.removeWhere((element) => element.isEmpty);
    try {
      state = ApiState(isLoading: true);

      final response =
          await snapshotService.postTargetProfileSnapshots(snapshots);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);

        SharedPreferencesService.setPreference('is_target_snapshots', true);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> postProfileImages(List<File> images) async {
    try {
      state = ApiState(isLoading: true);

      final response = await snapshotService.postImages(images);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);

        SharedPreferencesService.setPreference('is_profile_completed', true);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }
}

final snapshotServiceProviderImpl =
    StateNotifierProvider<SnapshotServiceProvider, ApiState>((ref) {
  return SnapshotServiceProvider(snapshotService: SnapshotService(), ref: ref);
});
