import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @signupEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Email'**
  String get signupEmail;

  /// No description provided for @signupPhone.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Phone'**
  String get signupPhone;

  /// No description provided for @welcomeMessage1.
  ///
  /// In en, this message translates to:
  /// **'Find Love in a Click'**
  String get welcomeMessage1;

  /// No description provided for @welcomeMessage2.
  ///
  /// In en, this message translates to:
  /// **'Pass Time with a Loved One'**
  String get welcomeMessage2;

  /// No description provided for @welcomeMessage3.
  ///
  /// In en, this message translates to:
  /// **'You know what? Click Below'**
  String get welcomeMessage3;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide your personal details to create your account'**
  String get registerSubtitle;

  /// No description provided for @firstname.
  ///
  /// In en, this message translates to:
  /// **'Firstname'**
  String get firstname;

  /// No description provided for @hintFirstname.
  ///
  /// In en, this message translates to:
  /// **'Enter your Firstname'**
  String get hintFirstname;

  /// No description provided for @validatorFirstname.
  ///
  /// In en, this message translates to:
  /// **'Your firstname should be present'**
  String get validatorFirstname;

  /// No description provided for @lastname.
  ///
  /// In en, this message translates to:
  /// **'Lastname'**
  String get lastname;

  /// No description provided for @hintLastname.
  ///
  /// In en, this message translates to:
  /// **'Enter your Lastname'**
  String get hintLastname;

  /// No description provided for @validatorLastname.
  ///
  /// In en, this message translates to:
  /// **'Your lastname should be present'**
  String get validatorLastname;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your Email'**
  String get hintEmail;

  /// No description provided for @validatorEmail.
  ///
  /// In en, this message translates to:
  /// **'Your email should be present'**
  String get validatorEmail;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @hintPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your Phone number'**
  String get hintPhoneNumber;

  /// No description provided for @validatorPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Your phone number should be present'**
  String get validatorPhoneNumber;

  /// No description provided for @otpVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get otpVerifyTitle;

  /// No description provided for @otpVerifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide one-time password generated to {username}'**
  String otpVerifySubtitle(String username);

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @hintPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your Password'**
  String get hintPassword;

  /// No description provided for @validatorPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password should be present'**
  String get validatorPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @generateCode.
  ///
  /// In en, this message translates to:
  /// **'Generate Login Code'**
  String get generateCode;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @hintNickname.
  ///
  /// In en, this message translates to:
  /// **'Enter your Nickname'**
  String get hintNickname;

  /// No description provided for @validatorNickname1.
  ///
  /// In en, this message translates to:
  /// **'Your nickname should be present'**
  String get validatorNickname1;

  /// No description provided for @validatorNickname2.
  ///
  /// In en, this message translates to:
  /// **'Your nickname requires a minimum of 3 characters'**
  String get validatorNickname2;

  /// No description provided for @nicknameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nickname should be chosen once. You will not be able to change it afterwards'**
  String get nicknameSubtitle;

  /// No description provided for @continuei.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuei;

  /// No description provided for @nicknameTitle.
  ///
  /// In en, this message translates to:
  /// **'My Nickname is'**
  String get nicknameTitle;

  /// No description provided for @dateOfBirthTitle.
  ///
  /// In en, this message translates to:
  /// **'My Date of Birth is'**
  String get dateOfBirthTitle;

  /// No description provided for @monthValidator1.
  ///
  /// In en, this message translates to:
  /// **''**
  String get monthValidator1;

  /// No description provided for @monthValidator2.
  ///
  /// In en, this message translates to:
  /// **''**
  String get monthValidator2;

  /// No description provided for @dayValidator1.
  ///
  /// In en, this message translates to:
  /// **''**
  String get dayValidator1;

  /// No description provided for @dayValidator2.
  ///
  /// In en, this message translates to:
  /// **''**
  String get dayValidator2;

  /// No description provided for @yearValidator1.
  ///
  /// In en, this message translates to:
  /// **''**
  String get yearValidator1;

  /// No description provided for @yearValidator2.
  ///
  /// In en, this message translates to:
  /// **''**
  String get yearValidator2;

  /// No description provided for @genderTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your Gender'**
  String get genderTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
