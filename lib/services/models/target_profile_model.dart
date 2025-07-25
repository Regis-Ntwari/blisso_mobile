// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

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
  String? feeling;
  File? profilePic;
  Map<String, dynamic>? subscription;
  List<dynamic>? lifesnapshots;
  List<dynamic>? targetLifesnapshots;
  List<dynamic>? profileImages;

  TargetProfileModel(
      {this.user,
      this.id,
      this.profilePic,
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
      this.feeling = 'Lucky \u{1F60A}'});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gender': gender,
      'lang': lang,
      'marital_status': maritalStatus,
      'show_me': showMe,
      'nickname': nickname,
      'dob': dob,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'distance_measure': distanceMeasure,
      'hide_profile': hideProfile,
      'home_address': homeAddress
    };
  }

  Map<String, dynamic> toMapNoProfile() {
    return <String, dynamic>{
      'gender': gender,
      'lang': lang,
      'marital_status': maritalStatus,
      'show_me': showMe,
      'nickname': nickname,
      'dob': dob,
      'profile_pic': profilePic,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'home_address': homeAddress,
      'distance_measure': distanceMeasure,
      'push_notifications': pushNotifications,
      'hide_profile': hideProfile,
      'login_code_enabled': loginCodeEnabled,
    };
  }

  Map<String, dynamic> toMapNoProfiles() {
    return <String, dynamic>{
      'gender': gender,
      'lang': lang,
      'marital_status': maritalStatus,
      'show_me': showMe,
      'nickname': nickname,
      'dob': dob,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'home_address': homeAddress,
      'distance_measure': distanceMeasure,
      'push_notifications': pushNotifications,
      'hide_profile': hideProfile,
      'login_code_enabled': loginCodeEnabled,
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
        feeling: map['feeling_caption'] != null
            ? '${map['feeling_caption']}${map['feeling_emojis']}'
            : null);
  }

  factory TargetProfileModel.fromMapNewNoProfile(Map<String, dynamic> map) {
    return TargetProfileModel(
        gender: map['gender'] != null ? map['gender'] as String : null,
        lang: map['lang'] != null ? map['lang'] as String : null,
        maritalStatus: map['marital_status'] != null
            ? map['marital_status'] as String
            : null,
        showMe: map['show_me'] != null ? map['show_me'] as String : null,
        nickname: map['nickname'] != null ? map['nickname'] as String : null,
        dob: map['dob'] != null ? map['dob'] as String : null,
        location: map['location'] != null ? map['location'] as String : null,
        latitude: map['latitude']?.toString(),
        longitude: map['longitude']?.toString(),
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
            map['home_address'] != null ? map['home_address'] as String : null);
        
  }

  factory TargetProfileModel.fromMapNew(Map<String, dynamic> map) {
    return TargetProfileModel(
        gender: map['gender'] != null ? map['gender'] as String : null,
        lang: map['lang'] != null ? map['lang'] as String : null,
        maritalStatus: map['marital_status'] != null
            ? map['marital_status'] as String
            : null,
        showMe: map['show_me'] != null ? map['show_me'] as String : null,
        nickname: map['nickname'] != null ? map['nickname'] as String : null,
        dob: map['dob'] != null ? map['dob'] as String : null,
        location: map['location'] != null ? map['location'] as String : null,
        latitude: map['latitude']?.toString(),
        longitude: map['longitude']?.toString(),
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
        profilePic: map['profilePic'],
        homeAddress:
            map['home_address'] != null ? map['home_address'] as String : null);
        
  }

  String toJson() => json.encode(toMap());

  factory TargetProfileModel.fromJson(String source) =>
      TargetProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
