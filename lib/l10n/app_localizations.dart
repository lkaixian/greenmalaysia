import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';

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
    Locale('ms'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'GreenMalaysia'**
  String get appName;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @nextBtn.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextBtn;

  /// No description provided for @doneBtn.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneBtn;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @orText.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orText;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get updateSuccess;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get updateError;

  /// Title for the login screen
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// Error message when inputs are empty
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFieldsError;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Label for Google Sign In button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInGoogle;

  /// Error message for Google Sign-In failure
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed. Please try again.'**
  String get googleSignInFailed;

  /// Message when user cancels Google Sign-In
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In was cancelled.'**
  String get googleSignInCancelled;

  /// Link text to go to registration page
  ///
  /// In en, this message translates to:
  /// **'New User? Sign Up Here'**
  String get signUpLink;

  /// Title for sign up page
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Link text for password recovery
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Dialog title for password reset
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// Instructions for password reset
  ///
  /// In en, this message translates to:
  /// **'Enter your email address. We will send you a link to create a new password.'**
  String get resetPasswordDesc;

  /// Button text to send reset email
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Success message after sending reset email
  ///
  /// In en, this message translates to:
  /// **'Reset link sent! Check your email.'**
  String get resetEmailSent;

  /// Label for full name input
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Label for birth date input
  ///
  /// In en, this message translates to:
  /// **'Birth Date (DD/MM/YYYY)'**
  String get birthDate;

  /// Checkbox label for EULA
  ///
  /// In en, this message translates to:
  /// **'I agree to the EULA (Click to read)'**
  String get agreeEula;

  /// Validation error for EULA
  ///
  /// In en, this message translates to:
  /// **'Please agree to EULA'**
  String get eulaError;

  /// Validation error for missing email
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get emailRequired;

  /// Title of the EULA dialog
  ///
  /// In en, this message translates to:
  /// **'End User License Agreement'**
  String get eulaDialogTitle;

  /// Content of the EULA dialog
  ///
  /// In en, this message translates to:
  /// **'1. You agree to recycle.\n2. You agree to drive safely.\n3. You agree not to spam the API.'**
  String get eulaDialogContent;

  /// Button label to proceed
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// Header for password requirements list
  ///
  /// In en, this message translates to:
  /// **'Password must contain:'**
  String get passwordReqTitle;

  /// Password requirement: length
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get reqMinChars;

  /// Password requirement: uppercase
  ///
  /// In en, this message translates to:
  /// **'At least 1 uppercase letter'**
  String get reqUppercase;

  /// Password requirement: digit
  ///
  /// In en, this message translates to:
  /// **'At least 1 number'**
  String get reqNumber;

  /// Title for OTP screen
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// Instruction text on OTP screen showing user email
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to\n{email}'**
  String otpSentPrompt(String email);

  /// Countdown timer text
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds} seconds'**
  String resendTimer(int seconds);

  /// Message shown when timer hits zero
  ///
  /// In en, this message translates to:
  /// **'Code expired.'**
  String get codeExpired;

  /// Button text to resend OTP
  ///
  /// In en, this message translates to:
  /// **'Resend OTP Now'**
  String get resendNow;

  /// Button text to verify code
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyBtn;

  /// Snackbar message (OTP arg is hidden in production)
  ///
  /// In en, this message translates to:
  /// **'OTP sent to {email}. (Code: {otp})'**
  String otpSentSnackbar(String email, String otp);

  /// Success dialog title
  ///
  /// In en, this message translates to:
  /// **'Verified!'**
  String get verifiedTitle;

  /// Success dialog body
  ///
  /// In en, this message translates to:
  /// **'OTP is correct. Welcome aboard!'**
  String get verifiedMessage;

  /// Failure dialog title
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get failedTitle;

  /// Failure dialog body
  ///
  /// In en, this message translates to:
  /// **'The OTP you entered is incorrect.'**
  String get failedMessage;

  /// AppBar title for Home
  ///
  /// In en, this message translates to:
  /// **'Home Dashboard'**
  String get dashboardTitle;

  /// Body text for Home
  ///
  /// In en, this message translates to:
  /// **'Welcome! Select an option below.'**
  String get welcomeMessage;

  /// FAB label for Camera
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// Bottom Nav label for Pickup
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// Bottom Nav label for Map
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// AppBar title for Notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// AppBar title for Analysis Page
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get aiAnalysis;

  /// Button text for manual analysis
  ///
  /// In en, this message translates to:
  /// **'Capture & Analyze'**
  String get captureAnalyze;

  /// Wizard step counter
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepProgress(int current, int total);

  /// Title for Pickup Page
  ///
  /// In en, this message translates to:
  /// **'Schedule Pickup'**
  String get schedulePickup;

  /// Step 1 Title
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get titleCategory;

  /// Step 1 Subtitle
  ///
  /// In en, this message translates to:
  /// **'What type of waste are you recycling?'**
  String get subtitleCategory;

  /// Step 2 Title
  ///
  /// In en, this message translates to:
  /// **'Pickup Details'**
  String get titleDetails;

  /// Label for address field
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get labelAddress;

  /// Switch to use saved address
  ///
  /// In en, this message translates to:
  /// **'Use Profile Address'**
  String get useProfileAddress;

  /// Hint text for address input
  ///
  /// In en, this message translates to:
  /// **'Enter pickup address'**
  String get hintAddress;

  /// Label for date picker
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// Placeholder for date picker
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Label for time dropdown
  ///
  /// In en, this message translates to:
  /// **'Time Slot'**
  String get labelTimeSlot;

  /// Button to start GPS search
  ///
  /// In en, this message translates to:
  /// **'Search Facilities'**
  String get searchFacilitiesBtn;

  /// Loading text during search
  ///
  /// In en, this message translates to:
  /// **'Locating nearby collectors...'**
  String get loadingCollectors;

  /// Error when search returns empty
  ///
  /// In en, this message translates to:
  /// **'No facilities found nearby.'**
  String get noFacilitiesFound;

  /// Button to go back to step 2
  ///
  /// In en, this message translates to:
  /// **'Change Address'**
  String get changeAddressBtn;

  /// Step 3 Title
  ///
  /// In en, this message translates to:
  /// **'Select Facility'**
  String get titleSelectFacility;

  /// Step 3 Subtitle
  ///
  /// In en, this message translates to:
  /// **'These collectors are near you.'**
  String get subtitleSelectFacility;

  /// Step 4 Title
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get titleConfirm;

  /// Step 4 Subtitle
  ///
  /// In en, this message translates to:
  /// **'Please review your details.'**
  String get subtitleConfirm;

  /// Label for category summary
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labelCategory;

  /// Label for facility summary
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get labelFacility;

  /// Final submit button
  ///
  /// In en, this message translates to:
  /// **'Submit Pickup Request'**
  String get submitRequestBtn;

  /// Success dialog title
  ///
  /// In en, this message translates to:
  /// **'Submitted!'**
  String get dialogSubmittedTitle;

  /// Success dialog body
  ///
  /// In en, this message translates to:
  /// **'Your pickup request has been sent. You will receive an email shortly.'**
  String get dialogSubmittedContent;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get errAddressRequired;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Please select Date and Time'**
  String get errDateTimeRequired;

  /// Error when GPS is blocked
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied'**
  String get errGpsPermission;

  /// AppBar title for Map
  ///
  /// In en, this message translates to:
  /// **'GPS Navigation'**
  String get gpsNavigation;

  /// Label for radius setting
  ///
  /// In en, this message translates to:
  /// **'Navigation Radius (m)'**
  String get radiusSet;

  /// Helper text for radius
  ///
  /// In en, this message translates to:
  /// **'Distance threshold for GPS detection'**
  String get radiusHelp;

  /// AppBar title for Profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Menu item
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// AppBar title for Personal Info page
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfoTitle;

  /// Menu item
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// Menu item
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// Menu item (Admin only)
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// Menu item (Driver only)
  ///
  /// In en, this message translates to:
  /// **'Collector Portal'**
  String get collectorDashboard;

  /// Button text
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated locally!'**
  String get profilePicUpdated;

  /// Greeting on profile page
  ///
  /// In en, this message translates to:
  /// **'Hello, {userName}'**
  String helloUser(String userName);

  /// Label for gender
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @selectSex.
  ///
  /// In en, this message translates to:
  /// **'Select Sex'**
  String get selectSex;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dob;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @pickupAddress.
  ///
  /// In en, this message translates to:
  /// **'Pickup Address'**
  String get pickupAddress;

  /// No description provided for @rewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsTitle;

  /// No description provided for @loginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please login first'**
  String get loginFirst;

  /// Display user points
  ///
  /// In en, this message translates to:
  /// **'{count} Points'**
  String pointsLabel(int count);

  /// Display membership tier
  ///
  /// In en, this message translates to:
  /// **'Membership: {level}'**
  String membershipLabel(String level);

  /// No description provided for @memberGreenStarter.
  ///
  /// In en, this message translates to:
  /// **'Green Starter'**
  String get memberGreenStarter;

  /// No description provided for @memberEcoWarrior.
  ///
  /// In en, this message translates to:
  /// **'Eco Warrior'**
  String get memberEcoWarrior;

  /// No description provided for @memberGreenMaster.
  ///
  /// In en, this message translates to:
  /// **'Green Master'**
  String get memberGreenMaster;

  /// No description provided for @noRewardsMsg.
  ///
  /// In en, this message translates to:
  /// **'No rewards for now! Check back later'**
  String get noRewardsMsg;

  /// Cost label on reward card
  ///
  /// In en, this message translates to:
  /// **'Cost: {cost} pts'**
  String costPts(int cost);

  /// No description provided for @redeemBtn.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeemBtn;

  /// No description provided for @redeemSuccess.
  ///
  /// In en, this message translates to:
  /// **'Redeemed! Check your email for the code.'**
  String get redeemSuccess;

  /// No description provided for @errOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock! No codes available.'**
  String get errOutOfStock;

  /// No description provided for @errInsufficientPoints.
  ///
  /// In en, this message translates to:
  /// **'Insufficient points!'**
  String get errInsufficientPoints;

  /// Generic error message with variable
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String errGeneric(String error);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @englishUK.
  ///
  /// In en, this message translates to:
  /// **'English (UK)'**
  String get englishUK;

  /// No description provided for @bahasaMelayu.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Melayu'**
  String get bahasaMelayu;

  /// No description provided for @aiAnalysisMode.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Mode'**
  String get aiAnalysisMode;

  /// No description provided for @liveMode.
  ///
  /// In en, this message translates to:
  /// **'Live Mode'**
  String get liveMode;

  /// No description provided for @nonLiveMode.
  ///
  /// In en, this message translates to:
  /// **'Non-Live Mode'**
  String get nonLiveMode;

  /// No description provided for @liveModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Camera scans continuously (Higher battery usage)'**
  String get liveModeSubtitle;

  /// No description provided for @nonLiveModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture photo to analyze (Default)'**
  String get nonLiveModeSubtitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @unlockAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Unlock Advanced Features'**
  String get unlockAdvanced;

  /// No description provided for @collectorPortal.
  ///
  /// In en, this message translates to:
  /// **'Collector Portal'**
  String get collectorPortal;

  /// No description provided for @tabNewRequests.
  ///
  /// In en, this message translates to:
  /// **'New Requests'**
  String get tabNewRequests;

  /// No description provided for @tabActiveJobs.
  ///
  /// In en, this message translates to:
  /// **'Active Jobs'**
  String get tabActiveJobs;

  /// No description provided for @noRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No requests found.'**
  String get noRequestsFound;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On The Way'**
  String get statusOnTheWay;

  /// No description provided for @btnReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get btnReject;

  /// No description provided for @btnAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get btnAccept;

  /// No description provided for @btnStartPickup.
  ///
  /// In en, this message translates to:
  /// **'Start Pickup (On The Way)'**
  String get btnStartPickup;

  /// No description provided for @btnCompleteReward.
  ///
  /// In en, this message translates to:
  /// **'Complete & Reward User'**
  String get btnCompleteReward;

  /// No description provided for @msgJobCompleted.
  ///
  /// In en, this message translates to:
  /// **'Job Completed! Points awarded.'**
  String get msgJobCompleted;

  /// Error message for status update failure
  ///
  /// In en, this message translates to:
  /// **'Error updating status: {error}'**
  String errStatusUpdate(String error);

  /// Email subject for reward redemption
  ///
  /// In en, this message translates to:
  /// **'Your Reward: {rewardTitle}'**
  String emailSubjectReward(String rewardTitle);

  /// Email body for reward redemption
  ///
  /// In en, this message translates to:
  /// **'<h1>Congrats!</h1><p>Here is your code: <b>{code}</b></p>'**
  String emailBodyCongrats(String code);

  /// No description provided for @emailSubjectComplete.
  ///
  /// In en, this message translates to:
  /// **'Pickup Completed! You earned points.'**
  String get emailSubjectComplete;

  /// Email body for pickup completion
  ///
  /// In en, this message translates to:
  /// **'<h1>Great Job!</h1><p>Your recycling pickup is complete. We added <b>{points} points</b> to your account.</p>'**
  String emailBodyComplete(int points);
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
      <String>['en', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
