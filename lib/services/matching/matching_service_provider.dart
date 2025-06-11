import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/matching/matching_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchingServiceProvider extends StateNotifier<ApiState> {
  final MatchingService matchingService;

  MatchingServiceProvider({required this.matchingService}) : super(ApiState());

  Future<void> getMatchingScores() async {
    state = ApiState(isLoading: true);

    try {
      final response = await matchingService.getMatchingRecommendations();

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(
            isLoading: false,
            error: response.errorMessage,
            statusCode: response.statusCode);
      } else {
        state = ApiState(
            isLoading: false,
            data: response.result,
            statusCode: response.statusCode);
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString(), statusCode: 500);
    }
  }
}

final matchingServiceProviderImpl =
    StateNotifierProvider<MatchingServiceProvider, ApiState>((ref) {
  return MatchingServiceProvider(matchingService: MatchingService());
});
