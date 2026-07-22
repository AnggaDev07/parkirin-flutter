# 🅿️ Parkirin - Sistem Pembayaran Parkir Cashless Kota Batam

**Parkirin** adalah aplikasi mobile pintar (*on-street parking*) yang dirancang khusus untuk memodernisasi sistem perparkiran di Kota Batam. Aplikasi ini mendigitalisasi proses pencatatan kendaraan dan memfasilitasi transaksi pembayaran secara *cashless*, menciptakan pengalaman parkir yang lebih transparan, cepat, dan efisien bagi pengemudi maupun juru parkir.

---

## 🛠️ Teknologi & Arsitektur (Tech Stack)

Aplikasi ini dibangun dengan fokus pada performa yang tinggi dan kode yang mudah dipelihara menggunakan **Flutter Clean Architecture** (dibagi ke dalam *Entities, Use Cases, Repository/Presenter, dan Data Source/UI*).

*   **Bahasa Pemrograman:** Dart[cite: 10]
*   **Kerangka Kerja (Framework):** Flutter[cite: 10]
*   **Basis Data (BaaS):** Firebase (Authentication & Firestore)[cite: 10]
*   **Payment Gateway:** Midtrans (Terintegrasi untuk metode pembayaran *cashless*)[cite: 10]
*   **Desain UI/UX:** Figma[cite: 10]

---

## ✨ Fitur Utama

Sistem ini memisahkan alur kerja menjadi dua peran (*role*) utama[cite: 10]:

### 🚗 Sisi Pengemudi (Driver)
*   **Autentikasi Mudah:** Mendaftar dan masuk menggunakan Nomor HP (verifikasi OTP) atau integrasi langsung dengan Akun Google[cite: 10].
*   **Manajemen Kendaraan (CRUD):** Mendaftarkan, memperbarui, atau menghapus plat nomor dan jenis kendaraan di dalam profil[cite: 10].
*   **Pembayaran Fleksibel:** Membayar tagihan parkir secara *cashless* melalui berbagai metode pembayaran (*Payment Gateway*), atau menggunakan sistem penukaran Poin (Redeem 2000 Poin untuk 1x parkir gratis)[cite: 10].
*   **Riwayat Parkir:** Memantau seluruh jejak aktivitas parkir dan status pembayaran yang pernah dilakukan[cite: 10].

### 👷 Sisi Juru Parkir (Parking Attendant)
*   **Login Aman:** Menggunakan Nomor Induk Juru Parkir (NIJP) dan kata sandi khusus yang terdaftar di sistem[cite: 10].
*   **Pembuatan Tiket Cepat:** Mencetak tiket parkir baru dengan menginput jenis kendaraan, plat nomor, dan metode pembayaran (*Tagih Driver* untuk pengguna aplikasi, atau *Catat Parkir* untuk pengguna non-aplikasi)[cite: 10].
*   **Fleksibilitas Edit:** Fitur pembaruan atau koreksi detail tiket parkir (berlaku sebelum batas waktu 10 menit sejak tiket dibuat)[cite: 10].
*   **Statistik Harian:** Dasbor khusus yang menampilkan jumlah total tiket, tiket pending, tiket terbayar, dan estimasi pendapatan secara *real-time*[cite: 10].

---