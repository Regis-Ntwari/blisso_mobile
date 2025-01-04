import 'dart:convert';
import 'dart:io';

class ProfileModel {
  String nickname;
  String dob;
  String location;
  String latitude;
  String longitude;
  File profilePic;
  String gender;
  String showMe;
  String maritalStatus;
  String lang;
  String homeAddress;

  ProfileModel(
      {required this.nickname,
      required this.dob,
      required this.location,
      required this.latitude,
      required this.longitude,
      required this.profilePic,
      required this.gender,
      required this.showMe,
      required this.maritalStatus,
      required this.lang,
      required this.homeAddress});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nickname': nickname,
      'dob': dob,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'profile_pic': profilePic,
      'gender': gender,
      'show_me': showMe,
      'marital_status': maritalStatus,
      'lang': lang,
      'home_address': homeAddress
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
        nickname: map['nickname'] as String,
        dob: map['dob'] as String,
        location: map['location'] as String,
        latitude: map['latitude'] as String,
        longitude: map['longitude'] as String,
        profilePic: map['profile_pic'] as File,
        gender: map['gender'] as String,
        showMe: map['show_me'] as String,
        maritalStatus: map['marital_status'] as String,
        lang: map['lang'] as String,
        homeAddress: map['home_address'] as String);
  }

  String toJson() => json.encode(toMap());

  factory ProfileModel.fromJson(String source) =>
      ProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
