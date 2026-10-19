
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'course_state.dart';
import 'models/course.dart';
import 'services/course_service.dart';
import 'repositories/course_repository.dart';

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
  // Repository langsung dibuat agar sudah siap digunakan.
  final CourseRepository courseRepository =
      CourseRepository(CourseService());

  bool isLoading = false;

  Future<void> openDetail(Course course) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(course: course),
      ),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            'Daftar Mata Kuliah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          FutureBuilder<List<Course>>(
            future: courseRepository.getCourses(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Gagal memuat data: ${snapshot.error}',
                    ),
                  ),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Card(
                  child: ListTile(
                    title: Text(
                      'Belum ada data mata kuliah.',
                    ),
                  ),
                );
              }

              final courses = snapshot.data!;

              return Column(
                children: courses.map((course) {
                  final isFavorite =
                      courseState.favorites.contains(
                    course.code,
                  );

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.school),
                      title: Text(course.title),
                      subtitle: Text(
                        'Kode: ${course.code}\n'
                        'SKS: ${course.credits} | '
                        'Status: ${course.status}',
                      ),
                      isThreeLine: true,
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
                              .toggleFavorite(course.code);
                        },
                      ),
                      onTap: isLoading
                          ? null
                          : () => openDetail(course),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Course course;

  const DetailPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseState>();

    final isFavorite =
        courseState.favorites.contains(course.code);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mata Kuliah'),
      ),
      body: Center(
        child: SingleChildScrollView(
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

              Text(
                course.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text('Kode: ${course.code}'),
              Text('SKS: ${course.credits}'),
              Text('Status: ${course.status}'),

              const SizedBox(height: 12),

              const Text('Data Mahasiswa'),
              const Text(studentName),
              const Text('NIM: $studentId'),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<CourseState>()
                      .toggleFavorite(course.code);
                },
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                label: Text(
                  isFavorite
                      ? 'Hapus dari Favorit'
                      : 'Tambah ke Favorit',
                ),
              ),

              const SizedBox(height: 8),

              OutlinedButton(
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
