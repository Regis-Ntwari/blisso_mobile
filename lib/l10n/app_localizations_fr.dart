// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get language => 'English';

  @override
  String get getStarted => 'Get Started';

  @override
  String get signupEmail => 'Sign up with Email';

  @override
  String get signupPhone => 'Sign up with Phone';

  @override
  String get welcomeMessage1 => 'Find Love in a Click';

  @override
  String get welcomeMessage2 => 'Pass Time with a Loved One';

  @override
  String get welcomeMessage3 => 'You know what? Click Below';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerSubtitle =>
      'Provide your personal details to create your account';

  @override
  String get firstname => 'Firstname';

  @override
  String get hintFirstname => 'Enter your Firstname';

  @override
  String get validatorFirstname => 'Your firstname should be present';

  @override
  String get lastname => 'Lastname';

  @override
  String get hintLastname => 'Enter your Lastname';

  @override
  String get validatorLastname => 'Your lastname should be present';

  @override
  String get email => 'Email';

  @override
  String get hintEmail => 'Enter your Email';

  @override
  String get validatorEmail => 'Your email should be present';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get hintPhoneNumber => 'Enter your Phone number';

  @override
  String get validatorPhoneNumber => 'Your phone number should be present';

  @override
  String get otpVerifyTitle => 'Verify OTP';

  @override
  String otpVerifySubtitle(String username) {
    return 'Provide one-time password generated to $username';
  }

  @override
  String get password => 'Password';

  @override
  String get hintPassword => 'Enter your Password';

  @override
  String get validatorPassword => 'Your password should be present';

  @override
  String get login => 'Login';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get generateCode => 'Generate Login Code';

  @override
  String get nickname => 'Nickname';

  @override
  String get hintNickname => 'Enter your Nickname';

  @override
  String get validatorNickname1 => 'Your nickname should be present';

  @override
  String get validatorNickname2 =>
      'Your nickname requires a minimum of 3 characters';

  @override
  String get nicknameSubtitle =>
      'Nickname should be chosen once. You will not be able to change it afterwards';

  @override
  String get continuei => 'Continue';

  @override
  String get nicknameTitle => 'My Nickname is';

  @override
  String get dateOfBirthTitle => 'My Date of Birth is';

  @override
  String get monthValidator1 => '';

  @override
  String get monthValidator2 => '';

  @override
  String get dayValidator1 => '';

  @override
  String get dayValidator2 => '';

  @override
  String get yearValidator1 => '';

  @override
  String get yearValidator2 => '';

  @override
  String get genderTitle => 'Choose your Gender';
}
