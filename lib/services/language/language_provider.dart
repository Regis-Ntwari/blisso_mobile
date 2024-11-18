import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageProvider extends StateNotifier<ApiState> {
  final SharedPreferencesService sharedPreferencesService;

  LanguageProvider(this.sharedPreferencesService) : super(ApiState());

  void getLanguage() async {
    return null;
  }
}
