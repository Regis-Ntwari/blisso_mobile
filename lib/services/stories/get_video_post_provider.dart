import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/stories/stories_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetVideoPostProvider extends StateNotifier<ApiState> {
  final StoriesService storiesService;

  GetVideoPostProvider({required this.storiesService}) : super(ApiState());

  Future<void> getVideoPosts() async {
    state = ApiState(isLoading: true);

    try {
      final response = await storiesService.getVideoPosts();

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(isLoading: false, error: response.errorMessage);
      } else {
        state = ApiState(isLoading: false, data: response.result);
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }

  Future<void> likeVideoPost(int id) async {

    try {
      

      final currentData = state.data;
      if (currentData == null || currentData is! List) return;

      final updatedVideos = List<Map<String, dynamic>>.from(currentData);

      final index = updatedVideos.indexWhere((video) => video['id'] == id);
      if (index == -1) return;

      final video = Map<String, dynamic>.from(updatedVideos[index]);

      bool liked = video['liked_this_story'] ?? false;

      String nickname = await SharedPreferencesService.getPreference('nickname');

      String profilePicture = await SharedPreferencesService.getPreference('profile_picture');

      if (liked) {
        // Dislike: remove user and decrement count
        video['liked_this_story'] = false;
        video['likes'] = (video['likes'] ?? 1) - 1;
        video['people_liked'] = (video['people_liked'] as List)
            .where((p) => p['nickname'] != nickname)
            .toList();
      } else {
        // Like: add user and increment count
        video['liked_this_story'] = true;
        video['likes'] = (video['likes'] ?? 0) + 1;
        video['people_liked'] = List.from(video['people_liked'] ?? [])
          ..add({
            'nickname': nickname,
            'profile_picture_uri': profilePicture,
            'has_profile_pic': true,
            'liked_at': DateTime.now().toLocal().toString(), // optional format
          });
      }

      updatedVideos[index] = video;

      state = ApiState(isLoading: false, data: updatedVideos);

      await storiesService.likeStory(id);
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      state = ApiState(isLoading: false, data: state.data, error: e.toString());
    }
  }
}

final getVideoPostProviderImpl =
    StateNotifierProvider<GetVideoPostProvider, ApiState>((ref) {
  return GetVideoPostProvider(storiesService: StoriesService());
});
