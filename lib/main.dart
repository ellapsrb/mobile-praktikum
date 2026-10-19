
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'course_state.dart';

const String studentName = 'Tina Ellina Wati';
const String studentId = '2415051043';

void main() {
  runApp(
    ChangeNotifierProvider<CourseState>(
      create: (_) => CourseState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Dashboard',
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
  bool isLoading = false;

  Future<void> openDetail() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DetailPage(),
      ),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // WATCH: mendengarkan perubahan jumlah favorit
    final courseState = context.watch<CourseState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(studentName),
              subtitle: Text('NIM: $studentId'),
            ),
          ),

          const SizedBox(height: 16),

          // Menggunakan watch untuk menampilkan jumlah favorit
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              title: const Text('Mata Kuliah Favorit'),
              subtitle: Text(
                '${courseState.favorites.length} favorit',
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Contoh State Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                // CONSUMER: membatasi bagian UI yang mendengarkan state
                Consumer<CourseState>(
                  builder: (context, state, child) {
                    final isFavorite =
                        state.favorites.contains('PTI001');

                    return ListTile(
                      title: const Text('Pemrograman Mobile'),
                      subtitle: const Text('ID: PTI001'),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        // READ: memanggil aksi tanpa listen
                        onPressed: () {
                          context
                              .read<CourseState>()
                              .toggleFavorite('PTI001');
                        },
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                Consumer<CourseState>(
                  builder: (context, state, child) {
                    final isFavorite =
                        state.favorites.contains('PTI002');

                    return ListTile(
                      title: const Text('Struktur Data'),
                      subtitle: const Text('ID: PTI002'),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          context
                              .read<CourseState>()
                              .toggleFavorite('PTI002');
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Contoh Penanganan Navigasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Buka Halaman Detail'),
              subtitle: const Text(
                'Mencegah navigasi berulang saat tombol ditekan.',
              ),
              trailing: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.arrow_forward_ios),
              onTap: isLoading ? null : openDetail,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Detail'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.school,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                studentName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text('NIM: $studentId'),
              const SizedBox(height: 24),
              const Text(
                'Ini adalah halaman detail aplikasi.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
