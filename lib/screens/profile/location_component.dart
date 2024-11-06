import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:blisso_mobile/services/location/location_service_provider.dart';

class LocationComponent extends ConsumerStatefulWidget {
  final Function onContinue;
  final Function onChangePosition;
  final Function onChangeAddress;
  const LocationComponent(
      {super.key,
      required this.onChangeAddress,
      required this.onContinue,
      required this.onChangePosition});

  @override
  ConsumerState<LocationComponent> createState() => _LocationComponentState();
}

class _LocationComponentState extends ConsumerState<LocationComponent> {
  String _location = 'Unknown';

  String _exactLocation = 'Unknown';

  Future<void> getLocation() async {
    Position position = await ref
        .read(locationServiceProviderImpl.notifier)
        .getLatitudeAndLongitude();

    widget.onChangePosition(position);

    String location = await ref
        .read(locationServiceProviderImpl.notifier)
        .getAddress(position);
    setState(() {
      _location =
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}';

      _exactLocation = location;
    });

    widget.onChangeAddress(location);
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(locationServiceProviderImpl);
    TextScaler textScaler = MediaQuery.textScalerOf(context);
    return userState.isLoading
        ? const LoadingScreen()
        : SizedBox(
            height: 500,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Location',
                        style: TextStyle(
                            fontSize: textScaler.scale(24),
                            color: GlobalColors.primaryColor)),
                    Text(_location,
                        style: TextStyle(fontSize: textScaler.scale(12))),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Exact Location',
                      style: TextStyle(
                          fontSize: textScaler.scale(24),
                          color: GlobalColors.primaryColor),
                    ),
                    Text(
                      _exactLocation,
                      style: TextStyle(
                        fontSize: textScaler.scale(12),
                      ),
                    )
                  ],
                ),
                ButtonComponent(
                  onTap: () async {
                    await getLocation();
                  },
                  text: 'Get Location',
                  backgroundColor: GlobalColors.whiteColor,
                  foregroundColor: GlobalColors.primaryColor,
                ),
                ButtonComponent(
                    text: 'Next',
                    backgroundColor: GlobalColors.primaryColor,
                    foregroundColor: GlobalColors.whiteColor,
                    onTap: () => widget.onContinue())
              ],
            ),
          );
  }
}
