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
  PaginatedProfilesNotifier(this.ref) : super(PaginatedState(isLoading: true));

  final Ref ref;

  String? _filterOption;
  String? _filterValue;
  double? _latitude;
  double? _longitude;

  /* ---------------- FIRST PAGE ---------------- */

  Future<void> loadFirstPage() async {
    state = state.copyWith(isLoading: true, data: [], currentPage: 1);

    try {
      final Position position = await ref
          .read(locationServiceProviderImpl.notifier)
          .getLatitudeAndLongitudeFast();

      _latitude = position.latitude;
      _longitude = position.longitude;

      await ref.read(profileServiceProviderImpl.notifier).getAllProfiles(
            page: 1,
            latitude: _latitude,
            longitude: _longitude,
          );

      final profilesData = ref.read(profileServiceProviderImpl);

      state = PaginatedState(
        data: profilesData.data as List,
        currentPage: profilesData.pagination['current_page'],
        totalPages: profilesData.pagination['total_pages'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /* ---------------- SEARCH ---------------- */

  Future<void> searchProfiles({
    required String filterOption,
    required String filterValue,
  }) async {
    if (filterValue.trim().isEmpty) return;

    _filterOption = filterOption;
    _filterValue = filterValue;

    state = state.copyWith(
      isLoading: true,
      data: [],
      currentPage: 1,
    );

    try {
      await ref.read(profileServiceProviderImpl.notifier).getAllProfiles(
            page: 1,
            latitude: _latitude,
            longitude: _longitude,
            filterOption: filterOption,
            filterValue: filterValue,
          );

      final profilesData = ref.read(profileServiceProviderImpl);

      state = PaginatedState(
        data: profilesData.data as List,
        currentPage: profilesData.pagination['current_page'],
        totalPages: profilesData.pagination['total_pages'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /* ---------------- CLEAR SEARCH ---------------- */

  Future<void> clearSearch() async {
    _filterOption = null;
    _filterValue = null;

    if (_latitude != null && _longitude != null) {
      state = state.copyWith(isLoading: true, data: [], currentPage: 1);

      try {
        await ref.read(profileServiceProviderImpl.notifier).getAllProfiles(
              page: 1,
              latitude: _latitude,
              longitude: _longitude,
            );

        final profilesData = ref.read(profileServiceProviderImpl);

        state = PaginatedState(
          data: profilesData.data as List,
          currentPage: profilesData.pagination['current_page'],
          totalPages: profilesData.pagination['total_pages'],
          isLoading: false,
        );
      } catch (e) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      }
    } else {
      await loadFirstPage();
    }
  }

  /* ---------------- PAGINATION ---------------- */

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.currentPage + 1;

    try {
      await ref.read(profileServiceProviderImpl.notifier).getAllProfiles(
            page: nextPage,
            latitude: _latitude,
            longitude: _longitude,
            filterOption: _filterOption,
            filterValue: _filterValue,
          );

      final profileData = ref.read(profileServiceProviderImpl);

      state = state.copyWith(
        data: [...state.data, ...(profileData.data as List)],
        currentPage: profileData.pagination['current_page'],
        totalPages: profileData.pagination['total_pages'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
