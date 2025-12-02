// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get dashboardTitle => 'Papan Pemuka';

  @override
  String get analysis => 'Analisis';

  @override
  String get pickup => 'Kutip';

  @override
  String get navigate => 'Navigasi';

  @override
  String get notifications => 'Pemberitahuan';

  @override
  String get profile => 'Profil';

  @override
  String get welcomeMessage => 'Selamat Datang! Pilih pilihan di bawah.';

  @override
  String get schedulePickup => 'Jadualkan Kutipan';

  @override
  String get gpsNavigation => 'Navigasi GPS';

  @override
  String get aiAnalysis => 'Analisis AI';

  @override
  String get captureAnalyze => 'Tangkap & Analisis';

  @override
  String helloUser(String userName) {
    return 'Halo, $userName';
  }

  @override
  String get loginTitle => 'Log Masuk';

  @override
  String get fillAllFieldsError => 'Sila isi semua ruang';

  @override
  String get appName => 'GreenMalaysia';

  @override
  String get email => 'Emel';

  @override
  String get password => 'Kata Laluan';

  @override
  String get orText => 'ATAU';

  @override
  String get signInGoogle => 'Log masuk dengan Google';

  @override
  String get signUpLink => 'Pengguna Baru? Daftar Di Sini';

  @override
  String get createAccount => 'Cipta Akaun';

  @override
  String get fullName => 'Nama Penuh';

  @override
  String get birthDate => 'Tarikh Lahir (HH/BB/TTTT)';

  @override
  String get agreeEula => 'Saya bersetuju dengan EULA (Klik untuk baca)';

  @override
  String get eulaError => 'Sila setuju dengan EULA';

  @override
  String get emailRequired => 'Emel diperlukan';

  @override
  String get eulaDialogTitle => 'Perjanjian Lesen Pengguna Akhir';

  @override
  String get eulaDialogContent =>
      '1. Anda bersetuju untuk mengitar semula.\n2. Anda bersetuju untuk memandu dengan selamat.\n3. Anda bersetuju untuk tidak spam API ini.';

  @override
  String get close => 'Tutup';

  @override
  String get back => 'Kembali';

  @override
  String get continueBtn => 'Teruskan';

  @override
  String get verifyOtp => 'Sahkan OTP';

  @override
  String otpSentPrompt(String email) {
    return 'Masukkan kod yang dihantar ke\n$email';
  }

  @override
  String resendTimer(int seconds) {
    return 'Hantar semula dalam $seconds saat';
  }

  @override
  String get codeExpired => 'Kod tamat tempoh.';

  @override
  String get resendNow => 'Hantar Semula OTP';

  @override
  String get verifyBtn => 'Sahkan';

  @override
  String otpSentSnackbar(String email, String otp) {
    return 'OTP dihantar ke $email. (Kod: $otp)';
  }

  @override
  String get verifiedTitle => 'Disahkan!';

  @override
  String get verifiedMessage => 'OTP betul. Selamat datang!';

  @override
  String get failedTitle => 'Pengesahan Gagal';

  @override
  String get failedMessage => 'OTP yang anda masukkan salah.';

  @override
  String get googleSignInFailed => 'Log Masuk Google Gagal. Sila cuba lagi.';

  @override
  String get googleSignInCancelled => 'Log Masuk Google dibatalkan.';
}
