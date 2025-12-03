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

  /// The main title displayed in the top AppBar of the home screen.
  ///
  /// In en, this message translates to:
  /// **'Home Dashboard'**
  String get dashboardTitle;

  /// Label for the central Floating Action Button (FAB) that opens the camera.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// Label for the navigation button used to schedule a recycling pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// Label for the navigation button used to open GPS maps.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// Title displayed on the Notifications screen.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Title displayed on the User Profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// The central body text shown to the user on the Home Screen before they interact.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Select an option below.'**
  String get welcomeMessage;

  /// AppBar title for the screen where users arrange a pickup time.
  ///
  /// In en, this message translates to:
  /// **'Schedule Pickup'**
  String get schedulePickup;

  /// AppBar title for the map and routing screen.
  ///
  /// In en, this message translates to:
  /// **'GPS Navigation'**
  String get gpsNavigation;

  /// AppBar title for the camera viewfinder screen.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get aiAnalysis;

  /// Text on the button that triggers the camera to take a picture.
  ///
  /// In en, this message translates to:
  /// **'Capture & Analyze'**
  String get captureAnalyze;

  /// Greeting displayed on the profile page with the user's name.
  ///
  /// In en, this message translates to:
  /// **'Hello, {userName}'**
  String helloUser(String userName);

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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'GreenMalaysia'**
  String get appName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @orText.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orText;

  /// Label for Google Sign In button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInGoogle;

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

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date (DD/MM/YYYY)'**
  String get birthDate;

  /// Checkbox label for EULA
  ///
  /// In en, this message translates to:
  /// **'I agree to the EULA (Click to read)'**
  String get agreeEula;

  /// No description provided for @eulaError.
  ///
  /// In en, this message translates to:
  /// **'Please agree to EULA'**
  String get eulaError;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get emailRequired;

  /// No description provided for @eulaDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'End User License Agreement'**
  String get eulaDialogTitle;

  /// No description provided for @eulaDialogContent.
  ///
  /// In en, this message translates to:
  /// **'1. You agree to recycle.\n2. You agree to drive safely.\n3. You agree not to spam the API.'**
  String get eulaDialogContent;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

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

  /// No description provided for @resendTimer.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds} seconds'**
  String resendTimer(int seconds);

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired.'**
  String get codeExpired;

  /// No description provided for @resendNow.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP Now'**
  String get resendNow;

  /// No description provided for @verifyBtn.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyBtn;

  /// No description provided for @otpSentSnackbar.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to {email}. (Code: {otp})'**
  String otpSentSnackbar(String email, String otp);

  /// No description provided for @verifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified!'**
  String get verifiedTitle;

  /// No description provided for @verifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'OTP is correct. Welcome aboard!'**
  String get verifiedMessage;

  /// No description provided for @failedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get failedTitle;

  /// No description provided for @failedMessage.
  ///
  /// In en, this message translates to:
  /// **'The OTP you entered is incorrect.'**
  String get failedMessage;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed. Please try again.'**
  String get googleSignInFailed;

  /// No description provided for @googleSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In was cancelled.'**
  String get googleSignInCancelled;

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

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfoTitle;

  /// No description provided for @sex.
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

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

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

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address. We will send you a link to create a new password.'**
  String get resetPasswordDesc;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent! Check your email.'**
  String get resetEmailSent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

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

  /// No description provided for @radiusSet.
  ///
  /// In en, this message translates to:
  /// **'Navigation Radius (m)'**
  String get radiusSet;

  /// No description provided for @radiusHelp.
  ///
  /// In en, this message translates to:
  /// **'Distance threshold for GPS detection'**
  String get radiusHelp;

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

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Points'**
  String pointsLabel(int count);

  /// No description provided for @membershipLabel.
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

  /// No description provided for @costPts.
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

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String errGeneric(Object error);

  /// No description provided for @emailSubjectReward.
  ///
  /// In en, this message translates to:
  /// **'Your Reward: {rewardTitle}'**
  String emailSubjectReward(Object rewardTitle);

  /// No description provided for @emailBodyCongrats.
  ///
  /// In en, this message translates to:
  /// **'<h1>Congrats!</h1><p>Here is your code: <b>{code}</b></p>'**
  String emailBodyCongrats(Object code);

  /// No description provided for @stepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepProgress(int current, int total);

  /// No description provided for @titleCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get titleCategory;

  /// No description provided for @subtitleCategory.
  ///
  /// In en, this message translates to:
  /// **'What type of waste are you recycling?'**
  String get subtitleCategory;

  /// No description provided for @nextBtn.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextBtn;

  /// No description provided for @titleDetails.
  ///
  /// In en, this message translates to:
  /// **'Pickup Details'**
  String get titleDetails;

  /// No description provided for @labelAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get labelAddress;

  /// No description provided for @useProfileAddress.
  ///
  /// In en, this message translates to:
  /// **'Use Profile Address'**
  String get useProfileAddress;

  /// No description provided for @hintAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter pickup address'**
  String get hintAddress;

  /// No description provided for @labelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// No description provided for @labelTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Time Slot'**
  String get labelTimeSlot;

  /// No description provided for @searchFacilitiesBtn.
  ///
  /// In en, this message translates to:
  /// **'Search Facilities'**
  String get searchFacilitiesBtn;

  /// No description provided for @loadingCollectors.
  ///
  /// In en, this message translates to:
  /// **'Locating nearby collectors...'**
  String get loadingCollectors;

  /// No description provided for @noFacilitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No facilities found nearby.'**
  String get noFacilitiesFound;

  /// No description provided for @changeAddressBtn.
  ///
  /// In en, this message translates to:
  /// **'Change Address'**
  String get changeAddressBtn;

  /// No description provided for @titleSelectFacility.
  ///
  /// In en, this message translates to:
  /// **'Select Facility'**
  String get titleSelectFacility;

  /// No description provided for @subtitleSelectFacility.
  ///
  /// In en, this message translates to:
  /// **'These collectors are near you.'**
  String get subtitleSelectFacility;

  /// No description provided for @titleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get titleConfirm;

  /// No description provided for @subtitleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please review your details.'**
  String get subtitleConfirm;

  /// No description provided for @labelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labelCategory;

  /// No description provided for @labelFacility.
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get labelFacility;

  /// No description provided for @submitRequestBtn.
  ///
  /// In en, this message translates to:
  /// **'Submit Pickup Request'**
  String get submitRequestBtn;

  /// No description provided for @dialogSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Submitted!'**
  String get dialogSubmittedTitle;

  /// No description provided for @dialogSubmittedContent.
  ///
  /// In en, this message translates to:
  /// **'Your pickup request has been sent. You will receive an email shortly.'**
  String get dialogSubmittedContent;

  /// No description provided for @doneBtn.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneBtn;

  /// No description provided for @errAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get errAddressRequired;

  /// No description provided for @errDateTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select Date and Time'**
  String get errDateTimeRequired;

  /// No description provided for @errGpsPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied'**
  String get errGpsPermission;

  /// No description provided for @passwordReqTitle.
  ///
  /// In en, this message translates to:
  /// **'Password must contain:'**
  String get passwordReqTitle;

  /// No description provided for @reqMinChars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get reqMinChars;

  /// No description provided for @reqUppercase.
  ///
  /// In en, this message translates to:
  /// **'At least 1 uppercase letter'**
  String get reqUppercase;

  /// No description provided for @reqNumber.
  ///
  /// In en, this message translates to:
  /// **'At least 1 number'**
  String get reqNumber;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @collectorDashboard.
  ///
  /// In en, this message translates to:
  /// **'Collector Portal'**
  String get collectorDashboard;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @profilePicUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated locally!'**
  String get profilePicUpdated;

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

  /// No description provided for @errStatusUpdate.
  ///
  /// In en, this message translates to:
  /// **'Error updating status: {error}'**
  String errStatusUpdate(Object error);

  /// No description provided for @emailSubjectComplete.
  ///
  /// In en, this message translates to:
  /// **'Pickup Completed! You earned points.'**
  String get emailSubjectComplete;

  /// No description provided for @emailBodyComplete.
  ///
  /// In en, this message translates to:
  /// **'<h1>Great Job!</h1><p>Your recycling pickup is complete. We added <b>{points} points</b> to your account.</p>'**
  String emailBodyComplete(Object points);
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
