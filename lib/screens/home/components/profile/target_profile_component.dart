import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/view_picture_component.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class TargetProfileComponent extends ConsumerStatefulWidget {
  const TargetProfileComponent({super.key});

  @override
  ConsumerState<TargetProfileComponent> createState() =>
      _TargetProfileComponentState();
}

class _TargetProfileComponentState
    extends ConsumerState<TargetProfileComponent> {
  String expandedField = '';

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final targetProfile = ref.watch(targetProfileProvider);
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () => Routemaster.of(context).push('/homepage'),
            child: const Icon(Icons.keyboard_arrow_left),
          ),
          centerTitle: true,
          title: Text(
            '${targetProfile.nickname}',
            style: TextStyle(
                color: GlobalColors.primaryColor, fontSize: scaler.scale(24)),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: width * 0.4,
                            width: width * 0.4,
                            child: InkWell(
                              onTap: () => showPictureDialog(
                                context: context,
                                image: {
                                  'image_uri': targetProfile.profilePictureUri!
                                },
                              ),
                              child: CachedNetworkImage(
                                  imageUrl: targetProfile.profilePictureUri!,
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Wrap(children: [
                            Text(
                              '${targetProfile.user!['first_name']} ${targetProfile.user!['last_name']}',
                              style: TextStyle(
                                  fontSize: scaler.scale(10),
                                  color: GlobalColors.secondaryColor),
                            ),
                          ]),
                          Wrap(children: [
                            Text(
                              '${targetProfile.user!['email']}',
                              style: TextStyle(
                                  fontSize: scaler.scale(10),
                                  color: GlobalColors.secondaryColor),
                            ),
                          ]),
                          SizedBox(
                            height: height * 0.2,
                            width: width * 0.8,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: GlobalColors.secondaryColor,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'About ${targetProfile.nickname}',
                                          style: TextStyle(
                                              fontSize: scaler.scale(20),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Wrap(
                                        alignment: WrapAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.cake,
                                          ),
                                          Text('${targetProfile.dob}')
                                        ],
                                      ),
                                      Wrap(
                                        alignment: WrapAlignment.start,
                                        children: [
                                          const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Icon(Icons.boy),
                                                Icon(Icons.girl),
                                              ]),
                                          Text('${targetProfile.gender}')
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Wrap(
                                        children: [
                                          const Icon(Icons.join_right_rounded),
                                          Text('${targetProfile.maritalStatus}')
                                        ],
                                      ),
                                      Wrap(
                                        children: [
                                          const Icon(Icons.language),
                                          Text('${targetProfile.lang}')
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Wrap(children: [
                                        const Icon(Icons.home),
                                        targetProfile.homeAddress == '' ||
                                                targetProfile.homeAddress ==
                                                    null
                                            ? const Text('Not Said')
                                            : Text(
                                                '${targetProfile.homeAddress}')
                                      ]),
                                      Wrap(children: [
                                        const Icon(Icons.check_circle),
                                        Text('${targetProfile.showMe}')
                                      ]),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  height: 50,
                  child: Align(
                    alignment: Alignment.center,
                    child: ButtonComponent(
                        text: 'DM Me',
                        backgroundColor: GlobalColors.primaryColor,
                        foregroundColor: GlobalColors.lightBackgroundColor,
                        onTap: () {}),
                  ),
                ),
              ),
              SizedBox(
                child: Column(
                  children: [
                    SizedBox(
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: targetProfile.profileImages!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: InkWell(
                                    onTap: () => showPictureDialog(
                                      context: context,
                                      image:
                                          targetProfile.profileImages![index],
                                    ),
                                    child: CachedNetworkImage(
                                        imageUrl:
                                            targetProfile.profileImages![index]
                                                ['image_uri']),
                                  ),
                                ),
                              );
                            },
                          ),
                        )),
                    InkWell(
                      onTap: () {
                        if (expandedField == 'interest') {
                          setState(() {
                            expandedField = '';
                          });
                        } else {
                          setState(() {
                            expandedField = 'interest';
                          });
                        }
                      },
                      child: ListTile(
                        title: Text(
                          'What ${targetProfile.nickname} like',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(targetProfile.lifesnapshots!
                            .map((snapshot) => snapshot['name'])
                            .join(", ")),
                        trailing: expandedField == 'interest'
                            ? const Icon(Icons.keyboard_arrow_down)
                            : const Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                    if (expandedField == 'interest')
                      SingleChildScrollView(
                        child: Wrap(
                          children: targetProfile.lifesnapshots!
                              .map<Widget>((snapshot) {
                            return ListTile(
                              title: Text(snapshot['name']),
                            );
                          }).toList(),
                        ),
                      ),
                    InkWell(
                      onTap: () {
                        if (expandedField == 'target') {
                          setState(() {
                            expandedField = '';
                          });
                        } else {
                          setState(() {
                            expandedField = 'target';
                          });
                        }
                      },
                      child: ListTile(
                        title: Text(
                            'What ${targetProfile.nickname} want in a person',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(targetProfile.targetLifesnapshots!
                            .map((snapshot) => snapshot['name'])
                            .join(", ")),
                        trailing: expandedField == 'target'
                            ? const Icon(Icons.keyboard_arrow_down)
                            : const Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                    if (expandedField == 'target')
                      SingleChildScrollView(
                        child: Wrap(
                          children: targetProfile.targetLifesnapshots!
                              .map<Widget>((snapshot) {
                            return ListTile(
                              title: Text(snapshot['name']),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
