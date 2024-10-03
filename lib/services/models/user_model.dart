class User {
  final String _id;
  String _firstname;
  String _lastname;
  String _username;
  String? _password;
  String? _accessToken;
  String? _refreshToken;

  User(
      {required String id,
      required String firstname,
      required String lastname,
      required String username})
      : _id = id,
        _firstname = firstname,
        _lastname = lastname,
        _username = username;

  String get id => _id;

  String get firstname => _firstname;

  String get lastname => _lastname;

  String get username => _username;

  String get password => _password!;

  String get accessToken => _accessToken!;

  String get refreshToken => _refreshToken!;

  set firstname(String value) {
    if (value.isNotEmpty) {
      _firstname = value;
    }
  }

  set lastname(String value) {
    if (value.isNotEmpty) {
      _lastname = value;
    }
  }

  set username(String value) {
    if (value.isNotEmpty) {
      _username = value;
    }
  }

  set password(String value) {
    if (value.isNotEmpty) {
      _password = value;
    }
  }

  set accessToken(String value) {
    if (value.isNotEmpty) {
      _accessToken = value;
    }
  }

  set refreshToken(String value) {
    if (value.isNotEmpty) {
      _refreshToken = value;
    }
  }
}
