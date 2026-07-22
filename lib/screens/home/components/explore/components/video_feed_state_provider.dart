// lib/services/video-post/video_feed_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set to true whenever any overlay/modal/screen that records audio or video
/// is open (e.g. the post-creation flow). The explore feed watches this and
/// pauses immediately.
final videoFeedSuppressedProvider = StateProvider<bool>((ref) => false);