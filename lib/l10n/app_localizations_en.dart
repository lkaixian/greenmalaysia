// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboardTitle => 'Home Dashboard';

  @override
  String get analysis => 'Analysis';

  @override
  String get pickup => 'Pickup';

  @override
  String get navigate => 'Navigate';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get welcomeMessage => 'Welcome! Select an option below.';

  @override
  String get schedulePickup => 'Schedule Pickup';

  @override
  String get gpsNavigation => 'GPS Navigation';

  @override
  String get aiAnalysis => 'AI Analysis';

  @override
  String get captureAnalyze => 'Capture & Analyze';

  @override
  String helloUser(String userName) {
    return 'Hello, $userName';
  }

  @override
  String get loginTitle => 'Login';

  @override
  String get fillAllFieldsError => 'Please fill in all fields';

  @override
  String get appName => 'GreenMalaysia';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get orText => 'OR';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String get signUpLink => 'New User? Sign Up Here';

  @override
  String get createAccount => 'Create Account';

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
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get continueBtn => 'Continue';

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
  String get googleSignInFailed => 'Google Sign-In failed. Please try again.';

  @override
  String get googleSignInCancelled => 'Google Sign-In was cancelled.';

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
  String get personalInfoTitle => 'Personal Information';

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
  String get selectDate => 'Select Date';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get pickupAddress => 'Pickup Address';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get updateSuccess => 'Profile updated successfully!';

  @override
  String get updateError => 'Failed to update profile';

  @override
  String get loading => 'Loading...';

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
  String get cancel => 'Cancel';
}
