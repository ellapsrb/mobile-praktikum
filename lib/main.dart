
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
  State<DebuggingPage> createState() => _DebuggingPageState();
}

class _DebuggingPageState extends State<DebuggingPage> {
  // Local state
  bool isLoading = false;

  // Tahap 3: shared state milik parent
  bool favorites = false;

  // Tahap 4: ValueNotifier untuk counter favorite
  final ValueNotifier<int> favoriteCount = ValueNotifier<int>(0);

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

  // Mengubah state favorite dan memperbarui counter
  void toggleFavorites() {
    setState(() {
      favorites = !favorites;
    });

    // Dua child menggunakan nilai favorite yang sama.
    favoriteCount.value = favorites ? 2 : 0;
  }

  @override
  void dispose() {
    favoriteCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debugging Challenge'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IDENTITAS
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      studentName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text('NIM: $studentId'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TAHAP 3: LIFTING STATE UP
            const Text(
              'Tahap 3 - Lifting State Up',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            FavoriteChild(
              title: 'Child 1',
              isFavorite: favorites,
              onFavoriteChanged: toggleFavorites,
            ),
            FavoriteChild(
              title: 'Child 2',
              isFavorite: favorites,
              onFavoriteChanged: toggleFavorites,
            ),

            const SizedBox(height: 25),

            // TAHAP 4: VALUENOTIFIER
            const Text(
              'Tahap 4 - ValueNotifier',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jumlah Favorite',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ValueListenableBuilder<int>(
                      valueListenable: favoriteCount,
                      builder: (context, value, child) {
                        return Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),
                    const Text(
                      'Tekan tombol favorite pada Child 1 '
                      'atau Child 2 untuk mengubah jumlahnya.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // KASUS A: RENDERFLEX OVERFLOW
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
                    const Icon(Icons.info, size: 30),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '$studentId - $studentName - '
                        'Teks panjang untuk menguji '
                        'RenderFlex overflow pada Row.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Solusi: Expanded membatasi Text pada '
              'ruang yang tersedia.',
            ),

            const SizedBox(height: 25),

            // KASUS B: LISTVIEW DALAM COLUMN
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text('Data ${index + 1}'),
                            subtitle: const Text('Data contoh'),
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
              'Solusi: Expanded memberikan batas tinggi '
              'kepada ListView.',
            ),

            const SizedBox(height: 25),

            // KASUS C: KEYBOARD OVERFLOW
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
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Nama',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
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
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Solusi: SingleChildScrollView membantu '
              'form tetap dapat diakses saat keyboard muncul.',
            ),

            const SizedBox(height: 25),

            // KASUS D: NAVIGASI GANDA
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
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : openDetail,
                    child: Text(
                      isLoading
                          ? 'Membuka halaman...'
                          : 'Buka Detail',
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // RINGKASAN
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Ringkasan Solusi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('A. Row → Expanded'),
                    Text('B. Column + ListView → Expanded'),
                    Text('C. Form → SingleChildScrollView'),
                    Text('D. Navigasi → cegah aksi ganda'),
                    Text('E. Counter → ValueNotifier'),
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

// CHILD FAVORITE
class FavoriteChild extends StatelessWidget {
  final String title;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;

  const FavoriteChild({
    super.key,
    required this.title,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
        ),
        title: Text(title),
        subtitle: Text(
          isFavorite ? 'Status: Favorite' : 'Status: Bukan Favorite',
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
          onPressed: onFavoriteChanged,
        ),
      ),
    );
  }
}

// DETAIL PAGE
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 70),
              const SizedBox(height: 20),
              const Text(
                'Navigasi berhasil dibuka',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(studentName),
              const Text('NIM: $studentId'),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
