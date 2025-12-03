// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GreenMalaysia';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get nextBtn => 'Next';

  @override
  String get doneBtn => 'Done';

  @override
  String get close => 'Close';

  @override
  String get loading => 'Loading...';

  @override
  String get orText => 'OR';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get updateSuccess => 'Profile updated successfully!';

  @override
  String get updateError => 'Failed to update profile';

  @override
  String get loginTitle => 'Login';

  @override
  String get fillAllFieldsError => 'Please fill in all fields';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String get googleSignInFailed => 'Google Sign-In failed. Please try again.';

  @override
  String get googleSignInCancelled => 'Google Sign-In was cancelled.';

  @override
  String get signUpLink => 'New User? Sign Up Here';

  @override
  String get createAccount => 'Create Account';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordDesc =>
      'Enter your email address. We will send you a link to create a new password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetEmailSent => 'Reset link sent! Check your email.';

  @override
  String get fullName => 'Full Name';

  @override
  String get birthDate => 'Birth Date (DD/MM/YYYY)';

  @override
  String get agreeEula => 'I agree to the EULA (Click to read)';

  @override
  String get eulaError => 'Please agree to EULA';

  @override
  String get emailRequired => 'Email required';

  @override
  String get eulaDialogTitle => 'End User License Agreement';

  @override
  String get eulaDialogContent =>
      '1. You agree to recycle.\n2. You agree to drive safely.\n3. You agree not to spam the API.';

  @override
  String get continueBtn => 'Continue';

  @override
  String get passwordReqTitle => 'Password must contain:';

  @override
  String get reqMinChars => 'At least 8 characters';

  @override
  String get reqUppercase => 'At least 1 uppercase letter';

  @override
  String get reqNumber => 'At least 1 number';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String otpSentPrompt(String email) {
    return 'Enter the code sent to\n$email';
  }

  @override
  String resendTimer(int seconds) {
    return 'Resend code in $seconds seconds';
  }

  @override
  String get codeExpired => 'Code expired.';

  @override
  String get resendNow => 'Resend OTP Now';

  @override
  String get verifyBtn => 'Verify';

  @override
  String otpSentSnackbar(String email, String otp) {
    return 'OTP sent to $email. (Code: $otp)';
  }

  @override
  String get verifiedTitle => 'Verified!';

  @override
  String get verifiedMessage => 'OTP is correct. Welcome aboard!';

  @override
  String get failedTitle => 'Verification Failed';

  @override
  String get failedMessage => 'The OTP you entered is incorrect.';

  @override
  String get dashboardTitle => 'Home Dashboard';

  @override
  String get welcomeMessage => 'Welcome! Select an option below.';

  @override
  String get analysis => 'Analysis';

  @override
  String get pickup => 'Pickup';

  @override
  String get navigate => 'Navigate';

  @override
  String get notifications => 'Notifications';

  @override
  String get aiAnalysis => 'AI Analysis';

  @override
  String get captureAnalyze => 'Capture & Analyze';

  @override
  String stepProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get schedulePickup => 'Schedule Pickup';

  @override
  String get titleCategory => 'Select Category';

  @override
  String get subtitleCategory => 'What type of waste are you recycling?';

  @override
  String get titleDetails => 'Pickup Details';

  @override
  String get labelAddress => 'Address';

  @override
  String get useProfileAddress => 'Use Profile Address';

  @override
  String get hintAddress => 'Enter pickup address';

  @override
  String get labelDate => 'Date';

  @override
  String get selectDate => 'Select Date';

  @override
  String get labelTimeSlot => 'Time Slot';

  @override
  String get searchFacilitiesBtn => 'Search Facilities';

  @override
  String get loadingCollectors => 'Locating nearby collectors...';

  @override
  String get noFacilitiesFound => 'No facilities found nearby.';

  @override
  String get changeAddressBtn => 'Change Address';

  @override
  String get titleSelectFacility => 'Select Facility';

  @override
  String get subtitleSelectFacility => 'These collectors are near you.';

  @override
  String get titleConfirm => 'Confirm Order';

  @override
  String get subtitleConfirm => 'Please review your details.';

  @override
  String get labelCategory => 'Category';

  @override
  String get labelFacility => 'Facility';

  @override
  String get submitRequestBtn => 'Submit Pickup Request';

  @override
  String get dialogSubmittedTitle => 'Submitted!';

  @override
  String get dialogSubmittedContent =>
      'Your pickup request has been sent. You will receive an email shortly.';

  @override
  String get errAddressRequired => 'Address is required';

  @override
  String get errDateTimeRequired => 'Please select Date and Time';

  @override
  String get errGpsPermission => 'Location permissions are denied';

  @override
  String get gpsNavigation => 'GPS Navigation';

  @override
  String get radiusSet => 'Navigation Radius (m)';

  @override
  String get radiusHelp => 'Distance threshold for GPS detection';

  @override
  String get profileTitle => 'Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get personalInfoTitle => 'Personal Information';

  @override
  String get rewards => 'Rewards';

  @override
  String get appSettings => 'App Settings';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get collectorDashboard => 'Collector Portal';

  @override
  String get logOut => 'Log Out';

  @override
  String get profilePicUpdated => 'Profile picture updated locally!';

  @override
  String helloUser(String userName) {
    return 'Hello, $userName';
  }

  @override
  String get sex => 'Sex';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get selectSex => 'Select Sex';

  @override
  String get dob => 'Date of Birth';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get pickupAddress => 'Pickup Address';

  @override
  String get rewardsTitle => 'Rewards';

  @override
  String get loginFirst => 'Please login first';

  @override
  String pointsLabel(int count) {
    return '$count Points';
  }

  @override
  String membershipLabel(String level) {
    return 'Membership: $level';
  }

  @override
  String get memberGreenStarter => 'Green Starter';

  @override
  String get memberEcoWarrior => 'Eco Warrior';

  @override
  String get memberGreenMaster => 'Green Master';

  @override
  String get noRewardsMsg => 'No rewards for now! Check back later';

  @override
  String costPts(int cost) {
    return 'Cost: $cost pts';
  }

  @override
  String get redeemBtn => 'Redeem';

  @override
  String get redeemSuccess => 'Redeemed! Check your email for the code.';

  @override
  String get errOutOfStock => 'Out of stock! No codes available.';

  @override
  String get errInsufficientPoints => 'Insufficient points!';

  @override
  String errGeneric(String error) {
    return 'Failed: $error';
  }

  @override
  String get settingsTitle => 'App Settings';

  @override
  String get language => 'Language';

  @override
  String get englishUK => 'English (UK)';

  @override
  String get bahasaMelayu => 'Bahasa Melayu';

  @override
  String get aiAnalysisMode => 'AI Analysis Mode';

  @override
  String get liveMode => 'Live Mode';

  @override
  String get nonLiveMode => 'Non-Live Mode';

  @override
  String get liveModeSubtitle =>
      'Camera scans continuously (Higher battery usage)';

  @override
  String get nonLiveModeSubtitle => 'Capture photo to analyze (Default)';

  @override
  String get theme => 'Theme';

  @override
  String get systemDefault => 'System Default';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get advanced => 'Advanced';

  @override
  String get unlockAdvanced => 'Unlock Advanced Features';

  @override
  String get collectorPortal => 'Collector Portal';

  @override
  String get tabNewRequests => 'New Requests';

  @override
  String get tabActiveJobs => 'Active Jobs';

  @override
  String get noRequestsFound => 'No requests found.';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusOnTheWay => 'On The Way';

  @override
  String get btnReject => 'Reject';

  @override
  String get btnAccept => 'Accept';

  @override
  String get btnStartPickup => 'Start Pickup (On The Way)';

  @override
  String get btnCompleteReward => 'Complete & Reward User';

  @override
  String get msgJobCompleted => 'Job Completed! Points awarded.';

  @override
  String errStatusUpdate(String error) {
    return 'Error updating status: $error';
  }

  @override
  String emailSubjectReward(String rewardTitle) {
    return 'Your Reward: $rewardTitle';
  }

  @override
  String emailBodyCongrats(String code) {
    return '<h1>Congrats!</h1><p>Here is your code: <b>$code</b></p>';
  }

  @override
  String get emailSubjectComplete => 'Pickup Completed! You earned points.';

  @override
  String emailBodyComplete(int points) {
    return '<h1>Great Job!</h1><p>Your recycling pickup is complete. We added <b>$points points</b> to your account.</p>';
  }
}
