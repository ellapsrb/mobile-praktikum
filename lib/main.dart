import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/course.dart';
import 'services/course_service.dart';
import 'repositories/course_repository.dart';
import 'supabase_config.dart';

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
      home: const CoursePage(),
    );
  }
}

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  late final CourseRepository repository;
  late Future<List<Course>> coursesFuture;

  final String studentName = 'Tina Ellina Wati';
  final String studentId = '2415051043';

  @override
  void initState() {
    super.initState();

    repository = CourseRepository(CourseService());
    coursesFuture = repository.getCourses();
  }

  void refreshCourses() {
    setState(() {
      coursesFuture = repository.getCourses();
    });
  }

  // FORM TAMBAH COURSE
  Future<void> showCourseForm() async {
    final formKey = GlobalKey<FormState>();

    final codeController = TextEditingController();
    final titleController = TextEditingController();
    final creditsController = TextEditingController();

    String status = 'planned';
    bool isSaving = false;

    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Tambah Mata Kuliah'),
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
                            hintText: 'Contoh: PTI104',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Kode wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Mata Kuliah',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Nama mata kuliah wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: creditsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah SKS',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final credits =
                                int.tryParse(value ?? '');

                            if (credits == null || credits < 1) {
                              return 'Masukkan SKS yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'planned',
                              child: Text('Planned'),
                            ),
                            DropdownMenuItem(
                              value: 'active',
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'done',
                              child: Text('Done'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                status = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.pop(dialogContext, false),
                    child: const Text('Batal'),
                  ),
                  FilledButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            setDialogState(() {
                              isSaving = true;
                            });

                            final course = Course(
                              code: codeController.text.trim(),
                              title: titleController.text.trim(),
                              credits: int.parse(
                                creditsController.text.trim(),
                              ),
                              status: status,
                            );

                            try {
                              await repository.createCourse(course);

                              if (!dialogContext.mounted) return;

                              Navigator.pop(dialogContext, true);
                            } catch (error) {
                              setDialogState(() {
                                isSaving = false;
                              });

                              ScaffoldMessenger.of(dialogContext)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal menambahkan course: $error',
                                  ),
                                ),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result == true && mounted) {
        refreshCourses();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course berhasil ditambahkan'),
          ),
        );
      }
    } finally {
      codeController.dispose();
      titleController.dispose();
      creditsController.dispose();
    }
  }

  // FORM EDIT COURSE
  Future<void> showEditCourseForm(Course course) async {
    if (course.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID course tidak ditemukan'),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();

    // Form otomatis terisi data course sebelumnya.
    final titleController = TextEditingController(
      text: course.title,
    );
    final creditsController = TextEditingController(
      text: course.credits.toString(),
    );

    String status = course.status.toLowerCase();

    if (!['planned', 'active', 'done'].contains(status)) {
      status = 'planned';
    }

    bool isSaving = false;

    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Edit Mata Kuliah'),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          initialValue: course.code,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Kode Mata Kuliah',
                            border: OutlineInputBorder(),
                            helperText: 'Kode tidak diubah pada tahap ini',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Mata Kuliah',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Nama mata kuliah wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: creditsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah SKS',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final credits =
                                int.tryParse(value ?? '');

                            if (credits == null || credits < 1) {
                              return 'Masukkan SKS yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'planned',
                              child: Text('Planned'),
                            ),
                            DropdownMenuItem(
                              value: 'active',
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'done',
                              child: Text('Done'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                status = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.pop(dialogContext, false),
                    child: const Text('Batal'),
                  ),
                  FilledButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            setDialogState(() {
                              isSaving = true;
                            });

                            // ID lama dipakai untuk menentukan baris
                            // yang akan diperbarui di Supabase.
                            final updatedCourse = Course(
                              id: course.id,
                              code: course.code,
                              title: titleController.text.trim(),
                              credits: int.parse(
                                creditsController.text.trim(),
                              ),
                              status: status,
                              createdAt: course.createdAt,
                            );

                            try {
                              await repository.updateCourse(
                                updatedCourse,
                              );

                              if (!dialogContext.mounted) return;

                              Navigator.pop(dialogContext, true);
                            } catch (error) {
                              setDialogState(() {
                                isSaving = false;
                              });

                              ScaffoldMessenger.of(dialogContext)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal memperbarui course: $error',
                                  ),
                                ),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Simpan Perubahan'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result == true && mounted) {
        refreshCourses();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course berhasil diperbarui'),
          ),
        );
      }
    } finally {
      titleController.dispose();
      creditsController.dispose();
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'done':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'Refresh data',
            onPressed: refreshCourses,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showCourseForm,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Course'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.indigo.withAlpha(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Profile',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('NIM: $studentId'),
                const SizedBox(height: 12),
                const Text(
                  'Daftar mata kuliah dari Supabase',
                ),
              ],
            ),
          ),
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
                          const Text(
                            'Gagal mengambil data dari Supabase.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: refreshCourses,
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
                    child: Text('Belum ada mata kuliah.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    final newFuture = repository.getCourses();

                    setState(() {
                      coursesFuture = newFuture;
                    });

                    await newFuture;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      12,
                      12,
                      90,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            child: Text('${course.credits}'),
                          ),
                          title: Text(
                            course.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('Kode: ${course.code}'),
                                Text('SKS: ${course.credits}'),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(
                                      course.status,
                                    ).withAlpha(25),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    course.status,
                                    style: TextStyle(
                                      color: getStatusColor(
                                        course.status,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isThreeLine: true,

                          // Tombol Edit di setiap course.
                          trailing: IconButton(
                            tooltip: 'Edit course',
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.indigo,
                            ),
                            onPressed: () {
                              showEditCourseForm(course);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}