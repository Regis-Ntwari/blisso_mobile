import 'package:blisso_mobile/services/matching/matching_service_provider.dart';
import 'package:blisso_mobile/services/paginated_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paginatedMatchingServiceProvider =
    StateNotifierProvider<PaginatedMatchingServiceNotifier, PaginatedState>(
  (ref) => PaginatedMatchingServiceNotifier(ref),
);

class PaginatedMatchingServiceNotifier extends StateNotifier<PaginatedState> {
  PaginatedMatchingServiceNotifier(this.ref) : super(PaginatedState());

  final Ref ref;

  Future<void> loadFirstPage() async {
    state = state.copyWith(isLoading: true, data: [], currentPage: 1);

    try {
      await ref
          .read(matchingServiceProviderImpl.notifier)
          .getMatchingScores(page: 1,);

      final matchingData = ref.read(matchingServiceProviderImpl);

      final data = matchingData.data as List;
      final pagination = matchingData.pagination;

      state = PaginatedState(
        data: data,
        currentPage: pagination['current_page'],
        totalPages: pagination['total_pages'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    final nextPage = state.currentPage + 1;

    try {
      await ref
          .read(matchingServiceProviderImpl.notifier)
          .getMatchingScores(page: nextPage);

      final matchingData = await ref.read(matchingServiceProviderImpl);

      final data = matchingData.data as List;
      final pagination = matchingData.pagination;

      state = state.copyWith(
        data: [...state.data, ...data],
        currentPage: pagination['current_page'],
        totalPages: pagination['total_pages'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
