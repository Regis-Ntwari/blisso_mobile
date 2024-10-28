import 'dart:convert';

import 'package:blisso_mobile/services/api_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationServiceProvider extends StateNotifier<ApiState> {
  LocationServiceProvider() : super(ApiState());

  Future<Position> _determineLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> getAddress(Position position) async {
    final configData = await rootBundle.loadString('assets/config/config.json');

    final configs = jsonDecode(configData);
    final response = await http.get(Uri.parse(
        '${configs['LOCATION_API_URL']}"/"${position.latitude},${position.longitude}&apiKey=${configs['LOCATION_API_KEY']}'));

    print(jsonDecode(response.body));
    return 'Hello';
  }
}
