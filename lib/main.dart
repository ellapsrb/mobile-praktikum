import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/course.dart';
import 'services/course_api_service.dart';
import 'repositories/course_repository.dart';
import 'supabase_config.dart';

const String studentName = 'Tina Ellina Wati';
const String studentId = '2415051043';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
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
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final CourseRepository repository;
  late Future<List<Course>> coursesFuture;

  @override
  void initState() {
    super.initState();

    repository = CourseRepository(CourseApiService());
    coursesFuture = repository.getCourses();
  }

  void reloadCourses() {
    setState(() {
      coursesFuture = repository.getCourses();
    });
  }

  String getCourseCode(Course course, int index) {
    if (course.code.isNotEmpty) {
      return course.code;
    }

    return 'MK-${(index + 1).toString().padLeft(2, '0')}';
  }

  String getCourseTitle(Course course) {
    const translations = {
      'sunt aut facere repellat provident occaecati excepturi optio reprehenderit':
          'Pengantar Pemrograman',
      'qui est esse': 'Dasar-Dasar Informatika',
      'ea molestias quasi exercitationem repellat qui ipsa sit aut':
          'Pemrograman Berorientasi Objek',
      'eum et est occaecati': 'Struktur Data',
      'nesciunt quas odio': 'Basis Data',
    };

    return translations[course.title] ?? course.title;
  }

  Future<void> showCourseForm({Course? course}) async {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(
      text: course?.code ?? '',
    );
    final titleController = TextEditingController(
      text: course?.title ?? '',
    );
    final creditsController = TextEditingController(
      text: course?.credits.toString() ?? '3',
    );
    final statusController = TextEditingController(
      text: course?.status ?? 'active',
    );

    final isEditing = course != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isEditing ? 'Edit Course' : 'Tambah Course',
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Kode Mata Kuliah',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Kode mata kuliah wajib diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Mata Kuliah',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama mata kuliah wajib diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: creditsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah SKS',
                    ),
                    validator: (value) {
                      if (value == null ||
                          int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Masukkan jumlah SKS yang valid';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: statusController,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Status wajib diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      final newCourse = Course(
        id: course?.id,
        userId: course?.userId ?? 1,
        code: codeController.text.trim(),
        title: titleController.text.trim(),
        credits: int.parse(creditsController.text.trim()),
        status: statusController.text.trim(),
      );

      try {
        if (isEditing) {
          if (course.id == null) {
            throw Exception('ID course tidak tersedia');
          }

          await repository.updateCourse(course.id!, newCourse);
        } else {
          await repository.createCourse(newCourse);
        }

        if (!mounted) return;

        reloadCourses();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Course berhasil diperbarui'
                  : 'Course berhasil ditambahkan',
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan course: $e'),
          ),
        );
      }
    }

    codeController.dispose();
    titleController.dispose();
    creditsController.dispose();
    statusController.dispose();
  }

  Future<void> deleteCourse(Course course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Course'),
          content: Text(
            'Yakin ingin menghapus "${course.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    if (course.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID course tidak tersedia'),
        ),
      );
      return;
    }

    try {
      await repository.deleteCourse(course.id!);

      if (!mounted) return;

      reloadCourses();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course berhasil dihapus'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus course: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
        actions: [
          IconButton(
            onPressed: reloadCourses,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang data',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Identitas Mahasiswa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Nama: $studentName'),
                Text('NIM: $studentId'),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daftar Mata Kuliah',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Course>>(
              future: coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Gagal mengambil data:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: reloadCourses,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final courses = snapshot.data ?? [];

                if (courses.isEmpty) {
                  return const Center(
                    child: Text('Belum ada mata kuliah'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: const Icon(
                                Icons.menu_book,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getCourseTitle(course),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kode: ${getCourseCode(course, index)}',
                                  ),
                                  Text(
                                    'SKS: ${course.credits == 0 ? 3 : course.credits}',
                                  ),
                                  Text('Status: ${course.status}'),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  showCourseForm(course: course);
                                } else if (value == 'delete') {
                                  deleteCourse(course);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Hapus'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCourseForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Course'),
      ),
    );
  }
}