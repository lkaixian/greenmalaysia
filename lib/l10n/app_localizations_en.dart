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
}
