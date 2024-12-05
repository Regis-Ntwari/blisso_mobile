import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:blisso_mobile/utils/global_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class ProfileSnapshotsComponent extends ConsumerStatefulWidget {
  final List<int> chosenValues;
  final Function checkInterest;
  final Function toggleInterest;
  final List<Map<String, List<Map<String, dynamic>>>> values;
  const ProfileSnapshotsComponent(
      {super.key,
      required this.chosenValues,
      required this.checkInterest,
      required this.toggleInterest,
      required this.values});

  @override
  ConsumerState<ProfileSnapshotsComponent> createState() =>
      _ProfileSnapshotsComponentState();
}

class _ProfileSnapshotsComponentState
    extends ConsumerState<ProfileSnapshotsComponent> {
  int detailsIndex = 0;

  late List<Map<String, List<Map<String, dynamic>>>> _filteredValues;

  @override
  void didUpdateWidget(covariant ProfileSnapshotsComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      setState(() {
        _filteredValues = widget.values
            .map((element) =>
                Map<String, List<Map<String, dynamic>>>.from(element))
            .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _copyList();
  }

  void _copyList() {
    setState(() {
      _filteredValues = widget.values
          .map((element) =>
              Map<String, List<Map<String, dynamic>>>.from(element))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final key = _filteredValues[detailsIndex].keys.elementAt(0);
    final values = _filteredValues[detailsIndex][key];
    return SizedBox(
      height: 500,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
              child: Text(
                'Choose your attributes',
                style: TextStyle(
                    fontSize: scaler.scale(GlobalFonts.title),
                    color: GlobalColors.primaryColor),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      if (!(detailsIndex <= 0)) {
                        setState(() {
                          detailsIndex = detailsIndex - 1;
                        });
                      }
                    },
                    child: Icon(
                      Icons.keyboard_arrow_left,
                      size: 30,
                      color: (!(detailsIndex <= 0))
                          ? GlobalColors.primaryColor
                          : GlobalColors.secondaryColor,
                    ),
                  ),
                  Text(key),
                  InkWell(
                    onTap: () {
                      if (!(detailsIndex >= _filteredValues.length - 1)) {
                        setState(() {
                          detailsIndex = detailsIndex + 1;
                        });
                      }
                    },
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      size: 30,
                      color: (!(detailsIndex >= _filteredValues.length - 1))
                          ? GlobalColors.primaryColor
                          : GlobalColors.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: values!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () => widget.toggleInterest(values[index]),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  border: Border.all(
                                      color: widget.checkInterest(values[index])
                                          ? GlobalColors.primaryColor
                                          : Colors.transparent)),
                              child: Card(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    values[index]['name'],
                                  ),
                                ),
                              ),
                            ),
                            widget.checkInterest(values[index])
                                ? const Positioned(
                                    child: Icon(
                                      Icons.verified,
                                      color: GlobalColors.primaryColor,
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            ButtonComponent(
                text: 'Submit',
                backgroundColor: GlobalColors.primaryColor,
                foregroundColor: GlobalColors.whiteColor,
                onTap: () {
                  if (widget.chosenValues.isEmpty) {
                    showPopupComponent(
                        context: context,
                        icon: Icons.dangerous,
                        message: 'Please choose atleast one interest');
                  } else {
                    ref
                        .read(snapshotServiceProviderImpl.notifier)
                        .postMyProfileSnapshots(widget.chosenValues);

                    final userState = ref.read(snapshotServiceProviderImpl);
                    if (userState.error != null) {
                      showSnackBar(context, userState.error!);
                    } else {
                      Routemaster.of(context).push(
                          '/auto-write/What do you want in your lover.../target-snapshot');
                    }
                  }
                })
          ],
        ),
      ),
    );
  }
}
