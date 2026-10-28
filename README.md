# Flutter REST API dan Supabase

## Deskripsi Aplikasi
Aplikasi ini merupakan project praktikum Pemrograman Mobile Pertemuan 7 yang mempelajari integrasi REST API, backend service, dan database menggunakan Flutter.

Aplikasi dikembangkan untuk menampilkan dan mengelola data mata kuliah serta mempelajari proses pengambilan data, pengolahan JSON, dan operasi CRUD.

## Identitas Mahasiswa
- Nama: Tina Ellina Wati
- NIM: 2415051043

## Teknologi yang Digunakan
- Flutter
- Dart
- REST API
- Supabase
- Git dan GitHub

## Fitur
- Mengambil data dari API/backend.
- Mengubah respons JSON menjadi model Dart.
- Menampilkan status loading, data, dan error.
- Menambahkan data mata kuliah.
- Mengubah data mata kuliah.
- Menghapus data mata kuliah.
- Menghubungkan aplikasi dengan database Supabase.

## Struktur Arsitektur
- `models/`: model data mata kuliah.
- `services/`: komunikasi dengan REST API atau Supabase.
- `repositories/`: perantara antara sumber data dan aplikasi.
- `providers/`: pengelolaan state aplikasi.
- `screens/`: halaman antarmuka aplikasi.
- `widgets/`: komponen antarmuka yang dapat digunakan kembali.

## Cara Menjalankan Aplikasi
1. Pastikan Flutter dan Dart sudah terpasang.
2. Clone repository ini.
3. Buka folder project melalui terminal.
4. Jalankan perintah:

   ```bash
   flutter pub get
   ```

5. Periksa kode menggunakan:

   ```bash
   dart analyze
   ```

6. Jalankan aplikasi di Chrome:

   ```bash
   flutter run -d chrome
   ```

## Backend
Project ini menggunakan REST API untuk mempelajari komunikasi HTTP dan pengolahan JSON, serta Supabase sebagai backend database untuk pengelolaan data mata kuliah.

## Keamanan
Credential server dan `service_role key` tidak boleh dimasukkan ke source code aplikasi Flutter atau diunggah ke repository publik. Akses database harus mengikuti konfigurasi keamanan dan kebijakan Row Level Security (RLS) yang sesuai.