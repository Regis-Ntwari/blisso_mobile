import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth_android/local_auth_android.dart';

class LocalAuthService {
  static final _auth = LocalAuthentication();

  static Future<bool> _canAuthenticate() async =>
      await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

  static Future<bool> authenticate() async {
    try {
      if (!await _canAuthenticate()) return false;

      return await _auth.authenticate(
          localizedReason: 'Please authenticate',
          authMessages: const [
            AndroidAuthMessages(
                signInTitle: 'Sign in', cancelButton: 'No thanks'),
            IOSAuthMessages(cancelButton: 'No thanks'),
          ],
          options: const AuthenticationOptions(
              useErrorDialogs: true, stickyAuth: true));
    } catch (err) {
      debugPrint("error $err");
      return false;
    }
  }
}
