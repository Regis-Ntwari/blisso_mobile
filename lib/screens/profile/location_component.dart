import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationComponent extends StatefulWidget {
  const LocationComponent({super.key});

  @override
  State<LocationComponent> createState() => _LocationComponentState();
}

class _LocationComponentState extends State<LocationComponent> {
  String _location = 'Unknown';
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Location: $_location'),
          ElevatedButton(
              onPressed: () async {
                Position position = await _determinePosition();
                setState(() {
                  _location =
                      'Lat: ${position.latitude}, Long: ${position.longitude}';
                });
              },
              child: const Text('Get Location'))
        ],
      ),
    );
  }

  Future<Position> _determinePosition() async {
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

    return await Geolocator.getCurrentPosition();
  }
}
