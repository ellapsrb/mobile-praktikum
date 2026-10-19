
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import 'course_state.dart';
import 'models/course.dart';

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

  // Membaca JSON dan mengubah data pertama menjadi objek Course.
  Future<Course> loadFirstCourse() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final courses = data['courses'] as List<dynamic>;

    if (courses.isEmpty) {
      throw Exception('Data mata kuliah masih kosong.');
    }

    return Course.fromJson(
      courses.first as Map<String, dynamic>,
    );
  }

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
    // WATCH: memantau perubahan jumlah favorit.
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

          // Menampilkan jumlah mata kuliah favorit.
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
            'Data Mata Kuliah dari JSON',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Tahap 8: mengubah JSON menjadi objek Course.
          FutureBuilder<Course>(
            future: loadFirstCourse(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Gagal membaca data: ${snapshot.error}',
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Text('Data mata kuliah tidak tersedia.');
              }

              final course = snapshot.data!;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: Text(course.title),
                  subtitle: Text(
                    'Kode: ${course.code}\n'
                    'SKS: ${course.credits}',
                  ),
                  trailing: Text(course.status),
                ),
              );
            },
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
                        // READ: menjalankan aksi toggle favorit.
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
            'Navigasi',
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
                'Contoh navigasi ke halaman detail.',
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
