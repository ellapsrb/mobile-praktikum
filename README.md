# flutter_ui_fundamentals

Project Flutter untuk praktikum Pemrograman Mobile.

## Identitas Mahasiswa

- Nama: Tina Ellina Wati
- NIM: 2415051043

## Tahap 1 — Membaca REST Endpoint dan JSON

### Informasi Endpoint

- URL Endpoint: https://jsonplaceholder.typicode.com/posts/1
- HTTP Method: GET
- Status Code: 200 OK
- Resource: posts

### Struktur Response JSON

Endpoint tersebut menghasilkan data dalam format JSON dengan empat field utama:

1. `userId`: ID pengguna yang membuat postingan.
2. `id`: ID postingan.
3. `title`: Judul postingan.
4. `body`: Isi postingan.

### Contoh Response JSON

    {
      "userId": 1,
      "id": 1,
      "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
      "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
    }

### Catatan

REST API digunakan untuk menghubungkan aplikasi dengan server melalui HTTP request. Pada tahap ini, metode GET digunakan untuk mengambil data dari server.

Response yang diterima berisi status code dan data dalam format JSON. Status code 200 OK menandakan bahwa permintaan berhasil diproses.

JSONPlaceholder digunakan sebagai REST API contoh untuk keperluan praktikum dan pengujian.

## Referensi Flutter

- https://docs.flutter.dev/get-started/learn-flutter
- https://docs.flutter.dev/get-started/codelab
- https://docs.flutter.dev/reference/learning-resources
- https://docs.flutter.dev/