import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TargetProfileProvider extends StateNotifier<TargetProfileModel> {
  TargetProfileProvider() : super(TargetProfileModel());

  void updateTargetProfile(TargetProfileModel targetProfileModel) {
    state = targetProfileModel;
  }
}

final targetProfileProvider =
    StateNotifierProvider<TargetProfileProvider, TargetProfileModel>((ref) {
  return TargetProfileProvider();
});
