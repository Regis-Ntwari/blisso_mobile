import 'dart:io';

import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnapshotServiceProvider extends StateNotifier<ApiState> {
  final SnapshotService snapshotService;

  SnapshotServiceProvider({required this.snapshotService}) : super(ApiState());

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
  return SnapshotServiceProvider(snapshotService: SnapshotService());
});
