import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:blisso_mobile/services/location/location_service_provider.dart';

class LocationComponent extends ConsumerStatefulWidget {
  final Function onContinue;
  final Function onChangePosition;
  final Function onChangeAddress;
  final Position? location;
  final TextEditingController homeAddress;
  const LocationComponent(
      {super.key,
      required this.onChangeAddress,
      required this.onContinue,
      required this.onChangePosition,
      required this.location,
      required this.homeAddress});

  @override
  ConsumerState<LocationComponent> createState() => _LocationComponentState();
}

class _LocationComponentState extends ConsumerState<LocationComponent> {
  Future<void> getLocation() async {
    Position position = await ref
        .watch(locationServiceProviderImpl.notifier)
        .getLatitudeAndLongitude();

    debugPrint(position.toString());

    widget.onChangePosition(position);

    // if (!mounted) return;
    // String location = await ref
    //     .read(locationServiceProviderImpl.notifier)
    //     .getAddress(position);
    // setState(() {
    //   _location =
    //       'Latitude: ${position.latitude}, Longitude: ${position.longitude}';

    //   _exactLocation = location;
    // });

    // widget.onChangeAddress(location);
  }

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler = MediaQuery.textScalerOf(context);
    return SizedBox(
      height: 500,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(
                Icons.location_on,
                color: GlobalColors.primaryColor,
                size: 40,
              ),
              Text('Location',
                  style: TextStyle(
                      fontSize: textScaler.scale(24),
                      color: GlobalColors.primaryColor)),
              Text(
                  widget.location == null
                      ? 'UNKNOWN'
                      : '${widget.location!.latitude}, ${widget.location!.longitude}',
                  style: TextStyle(fontSize: textScaler.scale(12))),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Location is needed to provide data according to your location',
                  style: TextStyle(
                      fontSize: 10, color: GlobalColors.secondaryColor),
                ),
              ),
              ButtonComponent(
                onTap: () async {
                  await getLocation();
                },
                text: 'Get Location',
                backgroundColor: GlobalColors.whiteColor,
                foregroundColor: GlobalColors.primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Form(
                  child: TextInputComponent(
                      controller: widget.homeAddress,
                      labelText: 'Home Address *',
                      hintText: 'Home Address',
                      validatorFunction: (value) {
                        return (value!.isEmpty ? value : null);
                      }),
                ),
              )
            ],
          ),
          // Column(
          //   children: [
          //     Text(
          //       'Exact Location',
          //       style: TextStyle(
          //           fontSize: textScaler.scale(24),
          //           color: GlobalColors.primaryColor),
          //     ),
          //     Text(
          //       _exactLocation,
          //       style: TextStyle(
          //         fontSize: textScaler.scale(12),
          //       ),
          //     )
          //   ],
          // ),

          ButtonComponent(
              text: 'Next',
              backgroundColor: GlobalColors.primaryColor,
              foregroundColor: GlobalColors.whiteColor,
              onTap: () {
                if (widget.location == null ||
                    widget.homeAddress.text.isEmpty) {
                  showPopupComponent(
                      context: context,
                      icon: Icons.dangerous,
                      message: widget.location == null
                          ? 'Please. Click on the button get location to get your precise location!'
                          : 'Please type in your home address');
                } else {
                  widget.onContinue();
                }
              })
        ],
      ),
    );
  }
}
