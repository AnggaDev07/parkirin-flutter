// lib/localization/app_localization.dart

import 'package:flutter/material.dart';

// Define enums for different translation categories
enum TranslationCategory {
  settingsPage,
  profileSection,
  alertsAndMessages,
  driverHomePage,
  bottomNavigation,
  dialogs,
  parkingAttendantHomePage,
  parkingAttendantNavigation,
  parkingAttendantActions,
  vehicleTypes,
  statusMessages,
  errors,
}

// Class to manage translations for a specific locale
class LocaleTranslations {
  final Map<String, String> _translations;

  const LocaleTranslations(this._translations);

  String get(String key) => _translations[key] ?? key;
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Lazy singleton for translations
  late final LocaleTranslations _translations =
      LocaleTranslations(_getTranslations());

  // Get translations based on current locale
  Map<String, String> _getTranslations() =>
      _localizedValues[locale.languageCode] ?? _localizedValues['en']!;

  // Translation getter
  String _t(String key) => _translations.get(key);

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Login Page
      'loginWelcome': 'Welcome to Parkirin!',
      'loginSubtitle':
          'Experience easy parking for Drivers & Attendants, with Cash & Cashless options!',
      'enterPhoneNumber': 'Enter your phone number',
      'phoneHint': '+1234567890',
      'loginButton': 'Login',
      'sendingOtp': 'Sending OTP...',
      'orDivider': 'OR',
      'signingIn': 'Signing in...',
      'signInWithGoogle': 'Sign in with Google',
      'enterNijp': 'Enter your NIJP',
      'nijpHint': 'Enter your NIJP number',
      'password': 'Password',
      'passwordHint': 'Enter your password',
      'fillAllFields': 'Please fill in all fields',

      // Role Selection
      'selectRole': 'Select your role',
      'driverRole': 'Driver',
      'driverDescription':
          'Find and book parking spots easily for your vehicle',
      'attendantRole': 'Parking Attendant',
      'attendantDescription':
          'Manage parking areas and handle vehicle check-ins/outs',

      // Settings Page
      'settings': 'Settings',
      'account': 'Account',
      'editProfile': 'Edit Profile',
      'language': 'Language',
      'theme': 'Theme',
      'darkMode': 'Dark Mode',
      'notifications': 'Notifications',
      'pushNotifications': 'Push Notifications',
      'emailNotifications': 'Email Notifications',
      'security': 'Security',
      'changePassword': 'Change Password',
      'biometricLogin': 'Biometric Login',
      'about': 'About',
      'version': 'Version',
      'privacyPolicy': 'Privacy Policy',
      'termsOfService': 'Terms of Service',
      'logout': 'Logout',
      'deleteAccount': 'Delete Account',

      // Vehicle list
      'myVehicles': 'My Vehicles',
      'addFirstVehicle': 'Add your first vehicle to get started',
      'noVehiclesYet': 'No vehicles yet',
      'vehicleCount': '%d Vehicles Registered',
      'addNewVehicle': 'Add New Vehicle',
      'tapToEdit': 'Tap to edit vehicle details',
      'deleteVehicle': 'Delete Vehicle',
      'deleteVehicleConfirm': 'Are you sure you want to delete this vehicle?',
      'thisActionCantBeUndone': 'This action cannot be undone',
      'vehiclePlateNumber': 'Plate Number:',

      // add vehicle
      'addVehicle': 'Add Vehicle',
      'vehicleDetails': 'Vehicle Details',
      'photoRequired': 'Vehicle photo is required',
      'vehicleType': 'Vehicle Type',
      'selectType': 'Select vehicle type',
      'plateNumber': 'Plate Number',
      'plateNumberHint': 'e.g., BP 1234 JK',
      'addVehicleSuccess': 'Vehicle added successfully!',
      'capturePhoto': 'Capture Photo',
      'chooseFromGallery': 'Choose from Gallery',
      'addPhoto': 'Add Vehicle Photo',
      'retakePhoto': 'Retake Photo',
      'changePhoto': 'Change Photo',
      'previewPhoto': 'Preview Photo',
      'vehicleAdded': 'Vehicle Added!',
      'vehicleAddedDesc': 'Your vehicle has been registered successfully',
      'backToVehicles': 'Back to My Vehicles',
      'processing': 'Processing...',
      'saveVehicle': 'Save Vehicle',
      'licensePlate': 'License Plate',
      'plateHint': 'e.g., BP 1234 JK',
      'plateFormat': 'Format: [AREA] [NUMBER] [SERIES]',
      'vehiclePhoto': 'Vehicle Photo',
      'addVehiclePhoto': 'Add Vehicle Photo',
      'tapToAddPhoto': 'Tap to take photo or choose from gallery',
      'takePhoto': 'Take Photo',
      'useCamera': 'Use your camera to take a photo',
      'selectFromGallery': 'Select a photo from your gallery',
      'cameraNotAvailable': 'Camera Not Available',
      'cameraSimulatorError':
          'The camera is not available in the iOS simulator. Please use a physical device for camera functionality or choose from gallery instead.',
      'errorPickingImage': 'Error picking image:',

      // edit vehicle
      'editVehicle': 'Edit Vehicle',
      'updateVehicle': 'Update Vehicle',
      'updatingVehicle': 'Updating...',
      'vehicleUpdated': 'Vehicle Updated!',
      'vehicleUpdatedDesc':
          'Your vehicle details have been successfully updated',
      'lastUpdated': 'Last updated %s',
      'saveChanges': 'Save Changes',
      'discardChanges': 'Discard Changes',
      'unsavedChanges': 'Unsaved Changes',
      'unsavedChangesDesc': 'Do you want to discard your changes?',
      'keep': 'Keep Editing',
      'discard': 'Discard',

      // Profile Section
      'name': 'Name',
      'email': 'Email',
      'phoneNumber': 'Phone Number',
      'save': 'Save',
      'cancel': 'Cancel',

      // Alerts and Messages
      'settingsUpdated': 'Settings updated successfully',
      'errorOccurred': 'An error occurred',
      'confirmLogout': 'Are you sure you want to logout?',
      'yes': 'Yes',
      'no': 'No',

      // Driver Home Page
      'goodMorning': 'Good Morning ☀️,',
      'goodAfternoon': 'Good Afternoon ☀️,',
      'goodEvening': 'Good Evening ☀️,',
      'goodNight': 'Good Night 🌙,',

      // POints Collection Info
      'pointsCollectionInfo': 'Collect 2000 points for a free parking!',
      'parkirinPoints': 'Parkirin Points',
      'pointsProgress': '%d% Progress',
      'pointsTarget': 'Target: %d pts',
      'remainingPoints': 'Collect %d more points for free parking!',
      'pointsSystem': 'Points System',
      'howItWorks': 'How it works',
      'earningPoints': 'Earning Points',
      'earningPointsDesc':
          'Get 40 points for each parking payment done with cashless method',
      'usingPoints': 'Using Points',
      'usingPointsDesc': 'Redeem 2000 points for one free parking session',
      'gotIt': 'Got it',

      'registeredVehicles': 'Total Vehicles',
      'totalBills': 'Total Bills',
      'latestBills': 'Latest Bills',
      'viewAll': 'View All',
      'overview': 'Overview',
      'stats': 'Stats',
      'manageVehicles': 'Manage Vehicles',
      'viewBills': 'View Bills',
      'vehicleManagement': 'Vehicle Management',
      'billManagement': 'Bill Management',

      // Bottom Navigation
      'navHome': 'Home',
      'navHistory': 'History',
      'navBills': 'Bills',
      'navProfile': 'Profile',
      'navSettings': 'Settings',

      // Dialogs
      'logoutConfirmation': 'Are you sure you want to logout?',

      // Parking Attendant Home Page
      'statsOverview': 'Statistics Overview',
      'locationDetails': 'Location Details',
      'recentActivity': 'Recent Activity',
      'totalTickets': 'Total Tickets',
      'paidTickets': 'Paid Tickets',
      'pendingTickets': 'Pending',
      'totalRevenue': 'Revenue',
      'location': 'Location',
      'district': 'District',
      'supervisor': 'Supervisor',
      'checkIn': 'Check-in',
      'checkOut': 'Check-out',

      'amount': 'Amount',
      'status': 'Status',
      'time': 'Time',
      'success': 'SUCCESS',
      'pending': 'PENDING',
      'cash': 'Cash',
      'cashless': 'Cashless',

      // Parking Attendant Navigation
      'navTickets': 'Tickets',
      'navPrint': 'Print',

      // Parking Attendant Actions
      'createTicket': 'Create Ticket',
      'scanQR': 'Scan QR',
      'printReceipt': 'Print Receipt',
      'selectPaymentType': 'Select Payment Type',
      'enterPlateNumber': 'Enter Plate Number',
      'selectVehicleType': 'Select Vehicle Type',
      'confirmTicket': 'Confirm Ticket',
      'editTicket': 'Edit Ticket',
      'cancelTicket': 'Cancel Ticket',

      // Vehicle Types
      'motorcycle': 'Motorcycle',
      'car': 'Car',
      'truck': 'Truck',
      'bus': 'Bus',

      // Status Messages
      'ticketCreated': 'Ticket Created Successfully',
      'ticketUpdated': 'Ticket Updated Successfully',
      'ticketCancelled': 'Ticket Cancelled',
      'printingReceipt': 'Printing Receipt...',
      'scanningQR': 'Scanning QR Code...',
      'processingPayment': 'Processing Payment...',

      // Errors
      'invalidPlateNumber': 'Invalid Plate Number',
      'printerError': 'Printer Error',
      'scannerError': 'Scanner Error',
      'connectionError': 'Connection Error',
      'tryAgain': 'Try Again',
    },
    'id': {
      // Login Page
      'loginWelcome': 'Selamat Datang di Parkirin!',
      'loginSubtitle':
          'Nikmati kemudahan parkir bagi Driver / Jukir, bisa Cash & Cashless!',
      'enterPhoneNumber': 'Masukkan nomor telepon',
      'phoneHint': '+62xxx-xxxx-xxxx',
      'loginButton': 'Masuk',
      'sendingOtp': 'Mengirim OTP...',
      'orDivider': 'ATAU',
      'signingIn': 'Sedang masuk...',
      'signInWithGoogle': 'Masuk dengan Google',
      'enterNijp': 'Masukkan NIJP Anda',
      'nijpHint': 'Masukkan nomor NIJP',
      'password': 'Kata Sandi',
      'passwordHint': 'Masukkan kata sandi',
      'fillAllFields': 'Mohon isi semua field',

      // Role Selection
      'selectRole': 'Pilih peran Anda',
      'driverRole': 'Driver',
      'driverDescription':
          'Temukan dan pesan tempat parkir dengan mudah untuk kendaraan Anda',
      'attendantRole': 'Juru Parkir',
      'attendantDescription':
          'Kelola area parkir dan tangani check-in/out kendaraan',

      // Settings Page
      'settings': 'Pengaturan',
      'account': 'Akun',
      'editProfile': 'Edit Profil',
      'language': 'Bahasa',
      'theme': 'Tema',
      'darkMode': 'Mode Gelap',
      'notifications': 'Notifikasi',
      'pushNotifications': 'Notifikasi Push',
      'emailNotifications': 'Notifikasi Email',
      'security': 'Keamanan',
      'changePassword': 'Ubah Kata Sandi',
      'biometricLogin': 'Login Biometrik',
      'about': 'Tentang',
      'version': 'Versi',
      'privacyPolicy': 'Kebijakan Privasi',
      'termsOfService': 'Ketentuan Layanan',
      'logout': 'Keluar',
      'deleteAccount': 'Hapus Akun',

      // Profile Section
      'name': 'Nama',
      'email': 'Email',
      'phoneNumber': 'Nomor Telepon',
      'save': 'Simpan',
      'cancel': 'Batal',

      // Vehicle list
      'myVehicles': 'Kendaraan Saya',
      'addFirstVehicle': 'Tambahkan kendaraan pertama Anda untuk memulai',
      'noVehiclesYet': 'Belum ada kendaraan',
      'vehicleCount': '%d Kendaraan Terdaftar',
      'addNewVehicle': 'Tambah Kendaraan Baru',
      'tapToEdit': 'Ketuk untuk mengedit kendaraan',
      'deleteVehicle': 'Hapus Kendaraan',
      'deleteVehicleConfirm':
          'Apakah Anda yakin ingin menghapus kendaraan ini?',
      'thisActionCantBeUndone': 'Tindakan ini tidak dapat dibatalkan',
      'vehiclePlateNumber': 'Nomor Plat:',

      // add vehicle
      'addVehicle': 'Tambah Kendaraan',
      'vehicleDetails': 'Detail Kendaraan',
      'photoRequired': 'Foto kendaraan wajib diisi',
      'vehicleType': 'Jenis Kendaraan',
      'selectType': 'Pilih jenis kendaraan',
      'plateNumber': 'Nomor Plat',
      'plateNumberHint': 'contoh: BP 1234 JK',
      'addVehicleSuccess': 'Kendaraan berhasil ditambahkan!',
      'capturePhoto': 'Ambil Foto',
      'chooseFromGallery': 'Pilih dari Galeri',
      'addPhoto': 'Tambah Foto Kendaraan',
      'retakePhoto': 'Ambil Ulang Foto',
      'changePhoto': 'Ganti Foto',
      'previewPhoto': 'Pratinjau Foto',
      'vehicleAdded': 'Kendaraan Ditambahkan!',
      'vehicleAddedDesc': 'Kendaraan Anda telah berhasil didaftarkan',
      'backToVehicles': 'Kembali ke Kendaraan Saya',
      'processing': 'Memproses...',
      'saveVehicle': 'Simpan Kendaraan',
      'licensePlate': 'Plat Nomor',
      'plateHint': 'contoh: BP 1234 JK',
      'plateFormat': 'Format: [AREA] [NOMOR] [SERI]',
      'vehiclePhoto': 'Foto Kendaraan',
      'addVehiclePhoto': 'Tambah Foto Kendaraan',
      'tapToAddPhoto': 'Ketuk untuk mengambil foto atau pilih dari galeri',
      'takePhoto': 'Ambil Foto',
      'useCamera': 'Gunakan kamera untuk mengambil foto',
      'selectFromGallery': 'Pilih foto dari galeri Anda',
      'cameraNotAvailable': 'Kamera Tidak Tersedia',
      'cameraSimulatorError':
          'Kamera tidak tersedia di simulator iOS. Silakan gunakan perangkat fisik untuk fungsi kamera atau pilih dari galeri.',
      'errorPickingImage': 'Error mengambil gambar:',

      // edit vehicle
      'editVehicle': 'Edit Kendaraan',
      'updateVehicle': 'Perbarui Kendaraan',
      'updatingVehicle': 'Memperbarui...',
      'vehicleUpdated': 'Kendaraan Diperbarui!',
      'vehicleUpdatedDesc': 'Detail kendaraan Anda telah berhasil diperbarui',
      'lastUpdated': 'Terakhir diperbarui %s',
      'saveChanges': 'Simpan Perubahan',
      'discardChanges': 'Buang Perubahan',
      'unsavedChanges': 'Perubahan Belum Disimpan',
      'unsavedChangesDesc': 'Apakah Anda ingin membuang perubahan?',
      'keep': 'Lanjutkan Edit',
      'discard': 'Buang',

      // Alerts and Messages
      'settingsUpdated': 'Pengaturan berhasil diperbarui',
      'errorOccurred': 'Terjadi kesalahan',
      'confirmLogout': 'Apakah Anda yakin ingin keluar?',
      'yes': 'Ya',
      'no': 'Tidak',

      // Driver Home Page
      'goodMorning': 'Selamat Pagi ☀️,',
      'goodAfternoon': 'Selamat Siang ☀️,',
      'goodEvening': 'Selamat Sore ☀️,',
      'goodNight': 'Selamat Malam 🌙,',

      // Points Collection Info
      'pointsCollectionInfo': 'Kumpulkan 2000 poin untuk parkir gratis!',
      'parkirinPoints': 'Poin Parkirin',
      'pointsProgress': 'Progress %d%',
      'pointsTarget': 'Target: %d poin',
      'remainingPoints': 'Kumpulkan %d poin lagi untuk parkir gratis!',
      'pointsSystem': 'Sistem Poin',
      'howItWorks': 'Cara Kerja',
      'earningPoints': 'Mendapatkan Poin',
      'earningPointsDesc':
          'Dapatkan 40 poin untuk setiap pembayaran parkir dengan metode cashless',
      'usingPoints': 'Menggunakan Poin',
      'usingPointsDesc': 'Tukarkan 2000 poin untuk satu sesi parkir gratis',
      'gotIt': 'Mengerti',

      'registeredVehicles': 'Total Kendaraan',
      'totalBills': 'Total Tagihan',
      'latestBills': 'Tagihan Terbaru',
      'viewAll': 'Selengkapnya',
      'overview': 'Ringkasan',
      'stats': 'Statistik',
      'manageVehicles': 'Kelola Kendaraan',
      'viewBills': 'Lihat Tagihan',
      'vehicleManagement': 'Manajemen Kendaraan',
      'billManagement': 'Manajemen Tagihan',

      // Bottom Navigation
      'navHome': 'Beranda',
      'navHistory': 'Riwayat',
      'navBills': 'Tagihan',
      'navProfile': 'Profil',
      'navSettings': 'Pengaturan',

      // Dialogs
      'logoutConfirmation': 'Apakah Anda yakin ingin keluar?',

      // Parking Attendant Home Page
      'statsOverview': 'Ikhtisar Statistik',
      'locationDetails': 'Detail Lokasi',
      'recentActivity': 'Aktivitas Terkini',
      'totalTickets': 'Total Tiket',
      'paidTickets': 'Tiket Terbayar',
      'pendingTickets': 'Pending',
      'totalRevenue': 'Pendapatan',
      'location': 'Lokasi',
      'district': 'Kecamatan',
      'supervisor': 'Korlap',
      'checkIn': 'Check-in',
      'checkOut': 'Check-out',

      'amount': 'Jumlah',
      'status': 'Status',
      'time': 'Waktu',
      'success': 'BERHASIL',
      'pending': 'TERTUNDA',
      'cash': 'Tunai',
      'cashless': 'Non-Tunai',

      // Parking Attendant Navigation
      'navTickets': 'Tiket',
      'navPrint': 'Cetak',

      // Parking Attendant Actions
      'createTicket': 'Buat Tiket',
      'scanQR': 'Scan QR',
      'printReceipt': 'Cetak Struk',
      'selectPaymentType': 'Pilih Jenis Pembayaran',
      'enterPlateNumber': 'Masukkan Nomor Plat',
      'selectVehicleType': 'Pilih Jenis Kendaraan',
      'confirmTicket': 'Konfirmasi Tiket',
      'editTicket': 'Edit Tiket',
      'cancelTicket': 'Batalkan Tiket',

      // Vehicle Types
      'motorcycle': 'Sepeda Motor',
      'car': 'Mobil',
      'truck': 'Truk',
      'bus': 'Bus',

      // Status Messages
      'ticketCreated': 'Tiket Berhasil Dibuat',
      'ticketUpdated': 'Tiket Berhasil Diperbarui',
      'ticketCancelled': 'Tiket Dibatalkan',
      'printingReceipt': 'Mencetak Struk...',
      'scanningQR': 'Memindai Kode QR...',
      'processingPayment': 'Memproses Pembayaran...',

      // Errors
      'invalidPlateNumber': 'Nomor Plat Tidak Valid',
      'printerError': 'Error Printer',
      'scannerError': 'Error Scanner',
      'connectionError': 'Error Koneksi',
      'tryAgain': 'Coba Lagi',
    },
  };

  // Helper method to get translations by category
  Map<String, String> getTranslationsForCategory(TranslationCategory category) {
    final prefix = _getCategoryPrefix(category);
    return Map.fromEntries(
      _getTranslations().entries.where((entry) => entry.key.startsWith(prefix)),
    );
  }

  String _getCategoryPrefix(TranslationCategory category) {
    switch (category) {
      case TranslationCategory.settingsPage:
        return 'settings';
      case TranslationCategory.profileSection:
        return 'profile';
      case TranslationCategory.alertsAndMessages:
        return 'alert';
      case TranslationCategory.driverHomePage:
        return 'driver';
      case TranslationCategory.bottomNavigation:
        return 'nav';
      case TranslationCategory.dialogs:
        return 'dialog';
      case TranslationCategory.parkingAttendantHomePage:
        return 'parkingAttendant';
      case TranslationCategory.parkingAttendantNavigation:
        return 'navParking';
      case TranslationCategory.parkingAttendantActions:
        return 'action';
      case TranslationCategory.vehicleTypes:
        return 'vehicle';
      case TranslationCategory.statusMessages:
        return 'status';
      case TranslationCategory.errors:
        return 'error';
    }
  }

  // Getters for all translations
  String get settings => _t('settings');
  String get account => _t('account');
  String get editProfile => _t('editProfile');
  String get language => _t('language');
  String get theme => _t('theme');
  String get darkMode => _t('darkMode');
  String get notifications => _t('notifications');
  String get pushNotifications => _t('pushNotifications');
  String get emailNotifications => _t('emailNotifications');
  String get security => _t('security');
  String get changePassword => _t('changePassword');
  String get biometricLogin => _t('biometricLogin');
  String get about => _t('about');
  String get version => _t('version');
  String get privacyPolicy => _t('privacyPolicy');
  String get termsOfService => _t('termsOfService');
  String get logout => _t('logout');
  String get overview => _t('overview');
  String get manageVehicles => _t('manageVehicles');
  String get viewBills => _t('viewBills');
  String get deleteAccount => _t('deleteAccount');
  String get name => _t('name');
  String get email => _t('email');
  String get phoneNumber => _t('phoneNumber');
  String get save => _t('save');
  String get cancel => _t('cancel');
  String get settingsUpdated => _t('settingsUpdated');
  String get errorOccurred => _t('errorOccurred');
  String get confirmLogout => _t('confirmLogout');
  String get yes => _t('yes');
  String get no => _t('no');
  String get goodMorning => _t('goodMorning');
  String get goodAfternoon => _t('goodAfternoon');
  String get goodEvening => _t('goodEvening');
  String get goodNight => _t('goodNight');

  // Points Collection Info
  String get pointsCollectionInfo => _t('pointsCollectionInfo');
  String get parkirinPoints => _t('parkirinPoints');
  String get pointsSystem => _t('pointsSystem');
  String get howItWorks => _t('howItWorks');
  String get earningPoints => _t('earningPoints');
  String get earningPointsDesc => _t('earningPointsDesc');
  String get usingPoints => _t('usingPoints');
  String get usingPointsDesc => _t('usingPointsDesc');
  String get gotIt => _t('gotIt');
  String get pointsProgress => _t('pointsProgress');
  String get pointsTarget => _t('pointsTarget');
  String get remainingPoints => _t('remainingPoints');

  // Vehicle list
  String get myVehicles => _t('myVehicles');
  String get addFirstVehicle => _t('addFirstVehicle');
  String get noVehiclesYet => _t('noVehiclesYet');
  String get vehicleCount => _t('vehicleCount');
  String get addNewVehicle => _t('addNewVehicle');
  String get tapToEdit => _t('tapToEdit');
  String get deleteVehicle => _t('deleteVehicle');
  String get deleteVehicleConfirm => _t('deleteVehicleConfirm');
  String get thisActionCantBeUndone => _t('thisActionCantBeUndone');
  String get vehiclePlateNumber => _t('vehiclePlateNumber');

  // add vehicle
  String get addVehicle => _t('addVehicle');
  String get vehicleDetails => _t('vehicleDetails');
  String get photoRequired => _t('photoRequired');
  String get vehicleType => _t('vehicleType');
  String get selectType => _t('selectType');
  String get plateNumber => _t('plateNumber');
  String get plateNumberHint => _t('plateNumberHint');
  String get addVehicleSuccess => _t('addVehicleSuccess');
  String get capturePhoto => _t('capturePhoto');
  String get chooseFromGallery => _t('chooseFromGallery');
  String get addPhoto => _t('addPhoto');
  String get retakePhoto => _t('retakePhoto');
  String get changePhoto => _t('changePhoto');
  String get previewPhoto => _t('previewPhoto');
  String get vehicleAdded => _t('vehicleAdded');
  String get vehicleAddedDesc => _t('vehicleAddedDesc');
  String get backToVehicles => _t('backToVehicles');
  String get processing => _t('processing');
  String get saveVehicle => _t('saveVehicle');
  String get licensePlate => _t('licensePlate');
  String get plateHint => _t('plateHint');
  String get plateFormat => _t('plateFormat');
  String get vehiclePhoto => _t('vehiclePhoto');
  String get addVehiclePhoto => _t('addVehiclePhoto');
  String get tapToAddPhoto => _t('tapToAddPhoto');
  String get takePhoto => _t('takePhoto');
  String get useCamera => _t('useCamera');
  String get selectFromGallery => _t('selectFromGallery');
  String get cameraNotAvailable => _t('cameraNotAvailable');
  String get cameraSimulatorError => _t('cameraSimulatorError');
  String get errorPickingImage => _t('errorPickingImage');

  // edit vehicle
  String get editVehicle => _t('editVehicle');
  String get updateVehicle => _t('updateVehicle');
  String get updatingVehicle => _t('updatingVehicle');
  String get vehicleUpdated => _t('vehicleUpdated');
  String get vehicleUpdatedDesc => _t('vehicleUpdatedDesc');
  String get lastUpdated => _t('lastUpdated');
  String get saveChanges => _t('saveChanges');
  String get discardChanges => _t('discardChanges');
  String get unsavedChanges => _t('unsavedChanges');
  String get unsavedChangesDesc => _t('unsavedChangesDesc');
  String get keep => _t('keep');
  String get discard => _t('discard');

  String get registeredVehicles => _t('registeredVehicles');
  String get totalBills => _t('totalBills');
  String get latestBills => _t('latestBills');
  String get viewAll => _t('viewAll');
  String get navHome => _t('navHome');
  String get navHistory => _t('navHistory');
  String get navBills => _t('navBills');
  String get navProfile => _t('navProfile');
  String get navSettings => _t('navSettings');
  String get logoutConfirmation => _t('logoutConfirmation');
  String get statsOverview => _t('statsOverview');
  String get locationDetails => _t('locationDetails');
  String get recentActivity => _t('recentActivity');
  String get totalTickets => _t('totalTickets');
  String get paidTickets => _t('paidTickets');
  String get pendingTickets => _t('pendingTickets');
  String get totalRevenue => _t('totalRevenue');
  String get location => _t('location');
  String get district => _t('district');
  String get supervisor => _t('supervisor');
  String get checkIn => _t('checkIn');
  String get checkOut => _t('checkOut');
  String get amount => _t('amount');
  String get status => _t('status');
  String get time => _t('time');
  String get success => _t('success');
  String get pending => _t('pending');
  String get cash => _t('cash');
  String get cashless => _t('cashless');
  String get navTickets => _t('navTickets');
  String get navPrint => _t('navPrint');
  String get createTicket => _t('createTicket');
  String get scanQR => _t('scanQR');
  String get printReceipt => _t('printReceipt');
  String get selectPaymentType => _t('selectPaymentType');
  String get enterPlateNumber => _t('enterPlateNumber');
  String get selectVehicleType => _t('selectVehicleType');
  String get confirmTicket => _t('confirmTicket');
  String get editTicket => _t('editTicket');
  String get cancelTicket => _t('cancelTicket');
  String get motorcycle => _t('motorcycle');
  String get car => _t('car');
  String get truck => _t('truck');
  String get bus => _t('bus');
  String get ticketCreated => _t('ticketCreated');
  String get ticketUpdated => _t('ticketUpdated');
  String get ticketCancelled => _t('ticketCancelled');
  String get printingReceipt => _t('printingReceipt');
  String get scanningQR => _t('scanningQR');
  String get processingPayment => _t('processingPayment');
  String get invalidPlateNumber => _t('invalidPlateNumber');
  String get printerError => _t('printerError');
  String get scannerError => _t('scannerError');
  String get connectionError => _t('connectionError');
  String get tryAgain => _t('tryAgain');

  // Login Page
  String get loginWelcome => _t('loginWelcome');
  String get loginSubtitle => _t('loginSubtitle');
  String get enterPhoneNumber => _t('enterPhoneNumber');
  String get phoneHint => _t('phoneHint');
  String get loginButton => _t('loginButton');
  String get sendingOtp => _t('sendingOtp');
  String get orDivider => _t('orDivider');
  String get signingIn => _t('signingIn');
  String get signInWithGoogle => _t('signInWithGoogle');
  String get enterNijp => _t('enterNijp');
  String get nijpHint => _t('nijpHint');
  String get password => _t('password');
  String get passwordHint => _t('passwordHint');
  String get fillAllFields => _t('fillAllFields');

  // Role Selection
  String get selectRole => _t('selectRole');
  String get driverRole => _t('driverRole');
  String get driverDescription => _t('driverDescription');
  String get attendantRole => _t('attendantRole');
  String get attendantDescription => _t('attendantDescription');

  // Helper methods for formatted translations
  String getFormattedMessage(String key, List<String> args) {
    String message = _t(key);
    for (var i = 0; i < args.length; i++) {
      message = message.replaceAll('{$i}', args[i]);
    }
    return message;
  }

  // Validation method for translation keys
  static bool hasTranslation(String key, String languageCode) {
    return _localizedValues[languageCode]?.containsKey(key) ?? false;
  }

  // Method to get all supported locales
  static List<Locale> get supportedLocales {
    return _localizedValues.keys.map((code) => Locale(code)).toList();
  }

  // Method to check if a locale is supported
  static bool isSupported(Locale locale) {
    return _localizedValues.containsKey(locale.languageCode);
  }

  // Debug helper to find missing translations
  static List<String> findMissingTranslations(
      String baseLanguage, String compareLanguage) {
    final baseTranslations = _localizedValues[baseLanguage] ?? {};
    final compareTranslations = _localizedValues[compareLanguage] ?? {};

    return baseTranslations.keys
        .where((key) => !compareTranslations.containsKey(key))
        .toList();
  }

  // Helper for pluralization
  String pluralize(String singularKey, String pluralKey, int count) {
    final key = count == 1 ? singularKey : pluralKey;
    return _t(key).replaceAll('{count}', count.toString());
  }

  // Helper for date formatting based on locale
  String formatDate(DateTime date) {
    if (locale.languageCode == 'id') {
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
    return '${date.month}/${date.day}/${date.year}';
  }

  // Helper for time formatting based on locale
  String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Helper for currency formatting based on locale
  String formatCurrency(double amount) {
    if (locale.languageCode == 'id') {
      return 'Rp${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }
}

// Extension for easy access to translations
extension BuildContextLocalization on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}

// Extension for string formatting helpers
extension StringFormatting on String {
  String fillWith(List<String> args) {
    String result = this;
    for (var i = 0; i < args.length; i++) {
      result = result.replaceAll('{$i}', args[i]);
    }
    return result;
  }
}
