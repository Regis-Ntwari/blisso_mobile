// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TargetProfileModel {
  Map<String, dynamic>? user;
  int? id;
  String? gender;
  String? lang;
  String? maritalStatus;
  String? showMe;
  String? nickname;
  String? dob;
  String? location;
  String? latitude;
  String? longitude;
  String? distanceMeasure;
  bool? pushNotifications;
  bool? hideProfile;
  bool? loginCodeEnabled;
  String? homeAddress;
  String? profilePictureUri;
  Map<String, dynamic>? subscription;
  List<dynamic>? lifesnapshots;
  List<dynamic>? targetLifesnapshots;
  List<dynamic>? profileImages;

  TargetProfileModel({
    this.user,
    this.id,
    this.gender,
    this.lang,
    this.maritalStatus,
    this.showMe,
    this.nickname,
    this.dob,
    this.location,
    this.latitude,
    this.longitude,
    this.distanceMeasure,
    this.pushNotifications,
    this.hideProfile,
    this.loginCodeEnabled,
    this.homeAddress,
    this.profilePictureUri,
    this.subscription,
    this.lifesnapshots,
    this.targetLifesnapshots,
    this.profileImages,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': user,
      'id': id,
      'gender': gender,
      'lang': lang,
      'maritalStatus': maritalStatus,
      'showMe': showMe,
      'nickname': nickname,
      'dob': dob,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'distanceMeasure': distanceMeasure,
      'pushNotifications': pushNotifications,
      'hideProfile': hideProfile,
      'loginCodeEnabled': loginCodeEnabled,
      'homeAddress': homeAddress,
      'profilePictureUri': profilePictureUri,
      'subscription': subscription,
      'lifesnapshots': lifesnapshots,
      'targetLifesnapshots': targetLifesnapshots,
      'profileImages': profileImages,
    };
  }

  factory TargetProfileModel.fromMap(Map<String, dynamic> map) {
    return TargetProfileModel(
      user: map['user'] != null
          ? Map<String, dynamic>.from((map['user'] as Map<String, dynamic>))
          : null,
      id: map['id'] != null ? map['id'] as int : null,
      gender: map['gender'] != null ? map['gender'] as String : null,
      lang: map['lang'] != null ? map['lang'] as String : null,
      maritalStatus: map['marital_status'] != null
          ? map['marital_status'] as String
          : null,
      showMe: map['show_me'] != null ? map['show_me'] as String : null,
      nickname: map['nickname'] != null ? map['nickname'] as String : null,
      dob: map['dob'] != null ? map['dob'] as String : null,
      location: map['location'] != null ? map['location'] as String : null,
      latitude: map['latitude'] != null ? map['latitude'] as String : null,
      longitude: map['longitude'] != null ? map['longitude'] as String : null,
      distanceMeasure: map['distance_measure'] != null
          ? map['distance_measure'] as String
          : null,
      pushNotifications: map['push_notifications'] != null
          ? map['push_notifications'] as bool
          : null,
      hideProfile:
          map['hide_profile'] != null ? map['hide_profile'] as bool : null,
      loginCodeEnabled: map['login_code_enabled'] != null
          ? map['login_code_enabled'] as bool
          : null,
      homeAddress:
          map['home_address'] != null ? map['home_address'] as String : null,
      profilePictureUri: map['profile_picture_uri'] != null
          ? map['profile_picture_uri'] as String
          : null,
      subscription: map['subscription'] != null
          ? Map<String, dynamic>.from(
              (map['subscription'] as Map<String, dynamic>))
          : null,
      lifesnapshots: map['lifesnapshots'] != null
          ? List<dynamic>.from((map['lifesnapshots'] as List<dynamic>))
          : null,
      targetLifesnapshots: map['target_lifesnapshots'] != null
          ? List<dynamic>.from((map['target_lifesnapshots'] as List<dynamic>))
          : null,
      profileImages: map['profile_images'] != null
          ? List<dynamic>.from((map['profile_images'] as List<dynamic>))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TargetProfileModel.fromJson(String source) =>
      TargetProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
