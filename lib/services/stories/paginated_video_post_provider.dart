import 'package:blisso_mobile/services/paginated_state.dart';
import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/services/stories/get_video_post_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paginatedVideoPostProvider =
    StateNotifierProvider<PaginatedVideoPostNotifier, PaginatedState>(
  (ref) => PaginatedVideoPostNotifier(ref),
);

class PaginatedVideoPostNotifier extends StateNotifier<PaginatedState> {
  PaginatedVideoPostNotifier(this.ref) : super(PaginatedState());

  final Ref ref;

  Future<void> loadFirstPage() async {
    state = state.copyWith(isLoading: true, data: [], currentPage: 1);

    try {
      await ref
          .read(getVideoPostProviderImpl.notifier)
          .getVideoPosts(page: 1);

      final videoPosts = ref.read(getVideoPostProviderImpl);

      final data = videoPosts.data as List;
      final pagination = videoPosts.pagination;

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

  

  /// Update a single video's like state directly in the paginated data,
  /// so rebuilds from this provider reflect the change immediately.
  void toggleVideoLike(String videoId, {required bool liked, required int likes}) {
    final idx = state.data.indexWhere(
      (v) => v['id'].toString() == videoId,
    );
    if (idx == -1) return;

    final updated = List<dynamic>.from(state.data);
    updated[idx] = Map<String, dynamic>.from(updated[idx] as Map)
      ..['liked_this_story'] = liked
      ..['likes'] = likes;
    state = state.copyWith(data: updated);
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    final nextPage = state.currentPage + 1;

    try {
      await ref
          .read(profileServiceProviderImpl.notifier)
          .getAllProfiles(page: nextPage);

      final profileData = await ref.read(profileServiceProviderImpl);

      final data = profileData.data as List;
      final pagination = profileData.pagination;

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
