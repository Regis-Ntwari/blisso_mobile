import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/users/all_user_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class AllUserServiceProvider extends StateNotifier<ApiState> {
  final AllUserService allUserService;

  AllUserServiceProvider({required this.allUserService}) : super(ApiState());

  Future<String> getFullName(String username) async {
    try {
      if (state.data == null) {
        await getAllUsers();
      }

      // Check if we have data and the username exists
      if (state.data != null &&
          state.data.containsKey(username) &&
          state.data[username] != null &&
          state.data[username]['full_name'] != null) {
        return state.data[username]['full_name'];
      }

      // If any of the above checks fail, return username as fallback
      return username;
    } catch (e) {
      debugPrint('Error getting full name: $e');
      return username; // Return username as fallback
    }
  }

  Future<String> getProfilePicture(String username) async {
    try {
      if (state.data == null) {
        await getAllUsers();
      }

      // Check if we have data and the profile picture exists
      print(state.data);
      if (state.data != null &&
          state.data.containsKey(username) &&
          state.data[username] != null &&
          state.data[username]['profile_picture_uri'] != null) {
        return state.data[username]['profile_picture_uri'];
      }

      // If any of the above checks fail, return empty string
      return '';
    } catch (e) {
      debugPrint('Error getting profile picture: $e');
      return ''; // Return empty string as fallback
    }
  }

  Future<void> getAllUsers() async {
    try {
      debugPrint('Starting getAllUsers fetch');
      state = ApiState(isLoading: true);
      final response = await allUserService.fetchAllUsers();
      debugPrint('getAllUsers response status: ${response.statusCode}');

      if (!StatusCodes.codes.contains(response.statusCode)) {
        debugPrint('getAllUsers error: ${response.errorMessage}');
        state = ApiState(
            isLoading: false,
            error: response.errorMessage,
            statusCode: response.statusCode);
        throw Exception(response.errorMessage);
      }

      debugPrint(
          'getAllUsers success, data keys: ${response.result?.keys.length}');
      state = ApiState(
          isLoading: false,
          data: response.result,
          statusCode: response.statusCode);
    } catch (e) {
      debugPrint('Error in getAllUsers: $e');
      state = ApiState(isLoading: false, error: e.toString(), statusCode: 500);
      throw e;
    }
  }
}

final allUserServiceProviderImpl =
    StateNotifierProvider<AllUserServiceProvider, ApiState>((ref) {
  // Create a singleton instance that persists across screens
  final AllUserServiceProvider _instance =
      AllUserServiceProvider(allUserService: AllUserService());
  return _instance;
});
