// State model for typing status
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TypingStatus {
  final String userId;
  final bool isTyping;
  final DateTime lastTypingTime;
  
  TypingStatus({
    required this.userId,
    required this.isTyping,
    required this.lastTypingTime,
  });
  
  TypingStatus copyWith({
    String? userId,
    bool? isTyping,
    DateTime? lastTypingTime,
  }) {
    return TypingStatus(
      userId: userId ?? this.userId,
      isTyping: isTyping ?? this.isTyping,
      lastTypingTime: lastTypingTime ?? this.lastTypingTime,
    );
  }
}

// Provider for managing typing states
final typingStatusProvider = StateNotifierProvider<TypingStatusNotifier, Map<String, TypingStatus>>(
  (ref) => TypingStatusNotifier(),
);

class TypingStatusNotifier extends StateNotifier<Map<String, TypingStatus>> {
  TypingStatusNotifier() : super({});
  
  void updateTypingStatus(String userId, bool isTyping) {
    state = {
      ...state,
      userId: TypingStatus(
        userId: userId,
        isTyping: isTyping,
        lastTypingTime: DateTime.now(),
      ),
    };
    
    // Auto-reset typing status after 3 seconds
    if (isTyping) {
      Future.delayed(const Duration(seconds: 2), () {
        if (state[userId]?.lastTypingTime == state[userId]?.lastTypingTime) {
          updateTypingStatus(userId, false);
        }
      });
    }
  }
  
  bool isUserTyping(String userId) {
    return state[userId]?.isTyping ?? false;
  }
}