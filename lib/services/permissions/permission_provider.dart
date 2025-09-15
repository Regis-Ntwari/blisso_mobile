import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionProvider extends StateNotifier<Map<String, dynamic>> {
  PermissionProvider() : super({});

  Future<void> updatePermissions(Map<String, dynamic> permissions) async {
    state = permissions;
  }
}

final permissionProviderImpl =
    StateNotifierProvider<PermissionProvider, Map<String, dynamic>>((ref) {
  return PermissionProvider();
});
