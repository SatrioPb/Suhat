# Supercalla Health (Suhat)

Aplikasi kesehatan dan kebugaran berbasis Flutter untuk Android, terinspirasi oleh pengalaman pengguna aplikasi Fitbeing. Aplikasi ini dirancang untuk membaca dan menampilkan metrik kesehatan dari smartwatch Supercalla melalui integrasi **Google Health Connect**.

---

## 📌 Status Pengembangan

- **Fase 1 (Validasi Teknis Health Connect):** ✅ Selesai
  - Integrasi pembacaan data nyata: Langkah (Steps), Detak Jantung (Heart Rate), dan Tidur (Sleep).
  - Konfigurasi izin granular Android Health Connect dan `FlutterFragmentActivity`.
  - Android debug APK build valid (`assembleDebug` lolos).
- **Fase 2 (Fondasi Aplikasi & Arsitektur):** ✅ Selesai
  - Struktur folder berlapis sesuai spesifikasi (Presentation, Application, Data Layer).
  - Implementasi `HealthConnectService`, `HealthRepository`, dan `PreferencesService`.
  - Manajemen state reaktif menggunakan `flutter_riverpod`.
  - Penanganan error terstruktur (`Failure` classes) dan pengujian unit komprehensif (21 tests passed).
- **Fase 3 (UI Dashboard):** ⏳ Direncanakan
- **Fase 4 (Riwayat & Pengaturan):** ⏳ Direncanakan

---

## 🔒 Kebijakan Sumber Data & Bluetooth

> **Pemberitahuan Keterhubungan:**
> Pada fase saat ini, seluruh data kesehatan dibaca secara nyata dari **Google Health Connect** (data yang disinkronkan oleh sensor perangkat atau aplikasi mitra seperti Fitbeing, Samsung Health, dsb.).
> 
> Aplikasi **tidak mengklaim** memiliki koneksi langsung via Bluetooth (BLE) sebelum modul koneksi Bluetooth native diimplementasikan dan diverifikasi pada fase roadmap berikutnya. Setiap metrik menampilkan stempel waktu (*timestamp*) aktual saat data diukur.

---

## 🛠️ Teknologi & Dependensi

- **Framework:** Flutter (Channel stable 3.19.3)
- **Bahasa:** Dart 3.3.1
- **Platform Target:** Android (minSdk 26, targetSdk 34, compileSdk 34)
- **Integrasi Kesehatan:** `health: ^13.1.3` (Google Health Connect)
- **State Management:** `flutter_riverpod: ^2.6.1`
- **Penyimpanan Lokal:** `shared_preferences: ^2.2.3`
- **Format Tanggal & Waktu:** `intl: ^0.20.2`

---

## 🚀 Menjalankan Aplikasi

### 1. Prasyarat
- Flutter SDK 3.19+ terpasang.
- Android Studio / Android SDK dengan build tools versi 34+.
- Perangkat Android fisik atau emulator (Android 8.0 Oreo / API 26 ke atas).
  - Pada Android 13 ke bawah, pastikan aplikasi *Health Connect* terpasang dari Google Play Store.
  - Pada Android 14+, Health Connect telah terintegrasi langsung di sistem operasi.

### 2. Instalasi & Pengujian
```bash
# Mengambil dependensi
flutter pub get

# Menjalankan static analysis
flutter analyze

# Menjalankan pengujian (unit & widget tests)
flutter test

# Melakukan build APK Android (Debug)
flutter build apk --debug
```

---

## 📁 Struktur Direktori

```text
lib/
├── app/
│   ├── app.dart
│   ├── providers.dart
│   └── theme.dart
├── core/
│   ├── constants/
│   ├── errors/
│   └── utils/
├── data/
│   ├── local/
│   ├── models/
│   ├── repositories/
│   └── services/
├── features/
│   └── health_connect/
└── main.dart
```

---

## 📄 Lisensi
Hak cipta © 2026 Tim Pengembang Supercalla Health.
