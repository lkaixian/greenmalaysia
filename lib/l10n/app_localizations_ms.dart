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

  @override
  String get settingsTitle => 'Tetapan Aplikasi';

  @override
  String get language => 'Bahasa';

  @override
  String get englishUK => 'English (UK)';

  @override
  String get bahasaMelayu => 'Bahasa Melayu';

  @override
  String get aiAnalysisMode => 'Mod Analisis AI';

  @override
  String get liveMode => 'Mod Langsung (Live)';

  @override
  String get nonLiveMode => 'Mod Bukan Langsung';

  @override
  String get liveModeSubtitle =>
      'Kamera mengimbas secara berterusan (Penggunaan bateri tinggi)';

  @override
  String get nonLiveModeSubtitle => 'Tangkap gambar untuk menganalisis (Lalai)';

  @override
  String get theme => 'Tema';

  @override
  String get systemDefault => 'Lalai Sistem';

  @override
  String get lightMode => 'Mod Cerah';

  @override
  String get darkMode => 'Mod Gelap';

  @override
  String get personalInfoTitle => 'Maklumat Peribadi';

  @override
  String get sex => 'Jantina';

  @override
  String get male => 'Lelaki';

  @override
  String get female => 'Perempuan';

  @override
  String get selectSex => 'Pilih Jantina';

  @override
  String get dob => 'Tarikh Lahir';

  @override
  String get selectDate => 'Pilih Tarikh';

  @override
  String get phoneNumber => 'Nombor Telefon';

  @override
  String get pickupAddress => 'Alamat Kutipan';

  @override
  String get saveChanges => 'Simpan Perubahan';

  @override
  String get updateSuccess => 'Profil berjaya dikemaskini!';

  @override
  String get updateError => 'Gagal mengemaskini profil';

  @override
  String get loading => 'Memuatkan...';

  @override
  String get forgotPassword => 'Lupa Kata Laluan?';

  @override
  String get resetPasswordTitle => 'Tetapkan Semula Kata Laluan';

  @override
  String get resetPasswordDesc =>
      'Masukkan emel anda. Kami akan menghantar pautan untuk cipta kata laluan baru.';

  @override
  String get sendResetLink => 'Hantar Pautan';

  @override
  String get resetEmailSent => 'Pautan dihantar! Semak emel anda.';

  @override
  String get cancel => 'Batal';

  @override
  String get advanced => 'Lanjutan';

  @override
  String get unlockAdvanced => 'Buka Ciri Lanjutan';

  @override
  String get radiusSet => 'Jejari Navigasi (m)';

  @override
  String get radiusHelp => 'Had jarak untuk pengesanan GPS';

  @override
  String get rewardsTitle => 'Ganjaran';

  @override
  String get loginFirst => 'Sila log masuk dahulu';

  @override
  String pointsLabel(int count) {
    return '$count Mata';
  }

  @override
  String membershipLabel(String level) {
    return 'Keahlian: $level';
  }

  @override
  String get memberGreenStarter => 'Pemula Hijau';

  @override
  String get memberEcoWarrior => 'Pejuang Eko';

  @override
  String get memberGreenMaster => 'Pakar Hijau';

  @override
  String get noRewardsMsg => 'Tiada ganjaran buat masa ini! Semak kemudian';

  @override
  String costPts(int cost) {
    return 'Kos: $cost mata';
  }

  @override
  String get redeemBtn => 'Tebus';

  @override
  String get redeemSuccess => 'Ditebus! Semak emel anda untuk kod.';

  @override
  String get errOutOfStock => 'Kehabisan stok! Tiada kod tersedia.';

  @override
  String get errInsufficientPoints => 'Mata tidak mencukupi!';

  @override
  String errGeneric(Object error) {
    return 'Gagal: $error';
  }

  @override
  String emailSubjectReward(Object rewardTitle) {
    return 'Ganjaran Anda: $rewardTitle';
  }

  @override
  String emailBodyCongrats(Object code) {
    return '<h1>Tahniah!</h1><p>Ini kod anda: <b>$code</b></p>';
  }

  @override
  String stepProgress(int current, int total) {
    return 'Langkah $current dari $total';
  }

  @override
  String get titleCategory => 'Pilih Kategori';

  @override
  String get subtitleCategory => 'Apakah jenis sampah yang anda kitar semula?';

  @override
  String get nextBtn => 'Seterusnya';

  @override
  String get titleDetails => 'Butiran Kutipan';

  @override
  String get labelAddress => 'Alamat';

  @override
  String get useProfileAddress => 'Guna Alamat Profil';

  @override
  String get hintAddress => 'Masukkan alamat kutipan';

  @override
  String get labelDate => 'Tarikh';

  @override
  String get labelTimeSlot => 'Slot Masa';

  @override
  String get searchFacilitiesBtn => 'Cari Fasiliti';

  @override
  String get loadingCollectors => 'Mencari pengumpul berdekatan...';

  @override
  String get noFacilitiesFound => 'Tiada fasiliti ditemui berdekatan.';

  @override
  String get changeAddressBtn => 'Tukar Alamat';

  @override
  String get titleSelectFacility => 'Pilih Fasiliti';

  @override
  String get subtitleSelectFacility => 'Pengumpul ini berada berdekatan anda.';

  @override
  String get titleConfirm => 'Sahkan Pesanan';

  @override
  String get subtitleConfirm => 'Sila semak butiran anda.';

  @override
  String get labelCategory => 'Kategori';

  @override
  String get labelFacility => 'Fasiliti';

  @override
  String get submitRequestBtn => 'Hantar Permintaan Kutipan';

  @override
  String get dialogSubmittedTitle => 'Dihantar!';

  @override
  String get dialogSubmittedContent =>
      'Permintaan kutipan anda telah dihantar. Anda akan menerima emel sebentar lagi.';

  @override
  String get doneBtn => 'Selesai';

  @override
  String get errAddressRequired => 'Alamat diperlukan';

  @override
  String get errDateTimeRequired => 'Sila pilih Tarikh dan Masa';

  @override
  String get errGpsPermission => 'Kebenaran lokasi ditolak';

  @override
  String get passwordReqTitle => 'Kata laluan mesti mengandungi:';

  @override
  String get reqMinChars => 'Sekurang-kurangnya 8 aksara';

  @override
  String get reqUppercase => 'Sekurang-kurangnya 1 huruf besar';

  @override
  String get reqNumber => 'Sekurang-kurangnya 1 nombor';

  @override
  String get profileTitle => 'Profil';

  @override
  String get personalInfo => 'Maklumat Peribadi';

  @override
  String get rewards => 'Ganjaran';

  @override
  String get appSettings => 'Tetapan Aplikasi';

  @override
  String get adminDashboard => 'Panel Admin';

  @override
  String get collectorDashboard => 'Portal Pengumpul';

  @override
  String get logOut => 'Log Keluar';

  @override
  String get profilePicUpdated => 'Gambar profil dikemaskini secara tempatan!';

  @override
  String get collectorPortal => 'Portal Pengumpul';

  @override
  String get tabNewRequests => 'Permintaan Baru';

  @override
  String get tabActiveJobs => 'Tugasan Aktif';

  @override
  String get noRequestsFound => 'Tiada permintaan ditemui.';

  @override
  String get statusPending => 'Menunggu';

  @override
  String get statusAccepted => 'Diterima';

  @override
  String get statusOnTheWay => 'Dalam Perjalanan';

  @override
  String get btnReject => 'Tolak';

  @override
  String get btnAccept => 'Terima';

  @override
  String get btnStartPickup => 'Mula Kutipan (Dalam Perjalanan)';

  @override
  String get btnCompleteReward => 'Selesai & Beri Ganjaran';

  @override
  String get msgJobCompleted => 'Tugasan Selesai! Mata diberikan.';

  @override
  String errStatusUpdate(Object error) {
    return 'Ralat mengemaskini status: $error';
  }

  @override
  String get emailSubjectComplete => 'Kutipan Selesai! Anda dapat mata.';

  @override
  String emailBodyComplete(Object points) {
    return '<h1>Syabas!</h1><p>Kutipan kitar semula anda selesai. Kami telah menambah <b>$points mata</b> ke akaun anda.</p>';
  }
}
