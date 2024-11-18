import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnapshotServiceProvider extends StateNotifier<ApiState> {
  final SnapshotService snapshotService;

  SnapshotServiceProvider({required this.snapshotService}) : super(ApiState());

  Future<dynamic> getLifeSnapshots() async {
    dynamic snapshots;

    try {
      state = ApiState(isLoading: true);

      snapshots = await snapshotService.fetchProfileSnapshots();

      print(snapshots);

      state = ApiState(data: snapshots, isLoading: false);
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }
}

final snapshotServiceProviderImpl =
    StateNotifierProvider<SnapshotServiceProvider, ApiState>((ref) {
  return SnapshotServiceProvider(snapshotService: SnapshotService());
});
