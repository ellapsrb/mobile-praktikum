import 'package:flutter/material.dart';

const String studentName = 'Tina Ellina Wati';
const String studentId = '2415051043';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Debugging Challenge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const DebuggingPage(),
    );
  }
}

class DebuggingPage extends StatefulWidget {
  const DebuggingPage({super.key});

  @override
  State<DebuggingPage> createState() =>
      _DebuggingPageState();
}

class _DebuggingPageState
    extends State<DebuggingPage> {
  bool isLoading = false;

  // ==================================================
  // KASUS D - MENCEGAH NAVIGASI GANDA
  // ==================================================

  Future<void> openDetail() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DetailPage(),
      ),
    );

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debugging Challenge'),
      ),

      // ==================================================
      // KASUS C - KEYBOARD OVERFLOW
      // ==================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // IDENTITAS
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      studentName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'NIM: 2415051043',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // KASUS A
            // ==================================================

            const Text(
              'Kasus A - RenderFlex Overflow',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info,
                      size: 30,
                    ),

                    const SizedBox(width: 8),

                    // Expanded memperbaiki overflow
                    const Expanded(
                      child: Text(
                        '$studentId - $studentName - '
                        'Teks ini dibuat panjang untuk '
                        'menguji masalah RenderFlex overflow '
                        'pada Row.',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Solusi: menggunakan Expanded agar Text '
              'hanya menggunakan ruang yang tersedia.',
            ),

            const SizedBox(height: 25),

            // ==================================================
            // KASUS B
            // ==================================================

            const Text(
              'Kasus B - ListView dalam Column',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: SizedBox(
                height: 220,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Daftar Data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Expanded memberikan batas tinggi
                    // kepada ListView
                    Expanded(
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                '${index + 1}',
                              ),
                            ),
                            title: Text(
                              'Data ${index + 1}',
                            ),
                            subtitle: const Text(
                              'Data contoh',
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Solusi: menggunakan Expanded agar ListView '
              'mendapatkan tinggi yang jelas.',
            ),

            const SizedBox(height: 25),

            // ==================================================
            // KASUS C
            // ==================================================

            const Text(
              'Kasus C - Keyboard Overflow',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Form Input',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Komentar',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Data berhasil diproses',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Simpan',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Solusi: menggunakan SingleChildScrollView '
              'agar form tetap dapat diakses ketika keyboard muncul.',
            ),

            const SizedBox(height: 25),

            // ==================================================
            // KASUS D
            // ==================================================

            const Text(
              'Kasus D - Navigasi Ganda',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Mencegah tombol ditekan berkali-kali',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            isLoading ? null : openDetail,
                        child: Text(
                          isLoading
                              ? 'Membuka halaman...'
                              : 'Buka Detail',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Solusi: tombol dinonaktifkan sementara '
              'ketika proses navigasi sedang berlangsung.',
            ),

            const SizedBox(height: 25),

            // RINGKASAN
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Ringkasan Solusi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'A. Row → Expanded',
                    ),
                    Text(
                      'B. Column + ListView → Expanded',
                    ),
                    Text(
                      'C. Form → SingleChildScrollView',
                    ),
                    Text(
                      'D. Navigasi → cegah aksi ganda',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// DETAIL PAGE
// ======================================================

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 70,
              ),

              const SizedBox(height: 20),

              const Text(
                'Navigasi berhasil dibuka',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                studentName,
              ),

              const Text(
                'NIM: 2415051043',
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Kembali',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}