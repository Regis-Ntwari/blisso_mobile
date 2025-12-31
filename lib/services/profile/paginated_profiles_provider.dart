import 'package:blisso_mobile/services/location/location_service_provider.dart';
import 'package:blisso_mobile/services/paginated_state.dart';
import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final paginatedProfilesProvider =
    StateNotifierProvider<PaginatedProfilesNotifier, PaginatedState>(
  (ref) => PaginatedProfilesNotifier(ref),
);

class PaginatedProfilesNotifier extends StateNotifier<PaginatedState> {
  PaginatedProfilesNotifier(this.ref) : super(PaginatedState());

  final Ref ref;

  Future<void> loadFirstPage() async {
    state = state.copyWith(isLoading: true, data: [], currentPage: 1);

    try {
      Position position = await ref
          .watch(locationServiceProviderImpl.notifier)
          .getLatitudeAndLongitude();
      await ref
          .read(profileServiceProviderImpl.notifier)
          .getAllProfiles(page: 1, latitude: position.latitude, longitude: position.longitude);

      final profilesData = ref.read(profileServiceProviderImpl);

      final data = profilesData.data as List;
      final pagination = profilesData.pagination;

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
    print("Loading next page");
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
