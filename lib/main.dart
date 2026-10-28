import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/course.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';
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
  final CourseRepository repository =
      CourseRepository(CourseService());

  List<Course> courses = [];
  bool isLoading = true;
  String? errorMessage;

  final String studentName = 'Tina Ellina Wati';
  final String studentId = '2415051043';

  @override
  void initState() {
    super.initState();
    refreshCourses();
  }

  // READ: Mengambil data mata kuliah dari Supabase.
  Future<void> refreshCourses() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await repository.getCourses();

      if (!mounted) return;

      setState(() {
        courses = result;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  // CREATE: Menampilkan formulir tambah mata kuliah.
  Future<void> showCourseForm() async {
    final formKey = GlobalKey<FormState>();

    final codeController = TextEditingController();
    final titleController = TextEditingController();
    final creditsController = TextEditingController();

    String selectedStatus = 'planned';
    bool isSaving = false;

    await showDialog<void>(
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

                          if (credits == null ||
                              credits < 1) {
                            return 'Masukkan jumlah SKS yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'planned',
                            child: Text('Planned'),
                          ),
                          DropdownMenuItem(
                            value: 'done',
                            child: Text('Done'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedStatus = value;
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
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!
                              .validate()) {
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            final course = Course(
                              code: codeController.text
                                  .trim()
                                  .toUpperCase(),
                              title:
                                  titleController.text.trim(),
                              credits: int.parse(
                                creditsController.text.trim(),
                              ),
                              status: selectedStatus,
                            );

                            await repository.createCourse(course);

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);

                            await refreshCourses();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Mata kuliah berhasil ditambahkan.',
                                ),
                              ),
                            );
                          } catch (error) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            if (!dialogContext.mounted) return;

                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal menambahkan mata kuliah: $error',
                                ),
                              ),
                            );
                          }
                        },
                  child: Text(
                    isSaving ? 'Menyimpan...' : 'Simpan',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    codeController.dispose();
    titleController.dispose();
    creditsController.dispose();
  }

  // UPDATE: Mengedit mata kuliah yang sudah ada.
  Future<void> showEditCourseForm(Course course) async {
    if (course.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID mata kuliah tidak ditemukan.'),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();

    final titleController =
        TextEditingController(text: course.title);
    final creditsController =
        TextEditingController(text: course.credits.toString());

    String selectedStatus = course.status;
    bool isSaving = false;

    const validStatuses = ['active', 'planned', 'done'];

    if (!validStatuses.contains(selectedStatus)) {
      selectedStatus = 'planned';
    }

    await showDialog<void>(
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

                          if (credits == null ||
                              credits < 1) {
                            return 'Masukkan jumlah SKS yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'planned',
                            child: Text('Planned'),
                          ),
                          DropdownMenuItem(
                            value: 'done',
                            child: Text('Done'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedStatus = value;
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
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!
                              .validate()) {
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            final updatedCourse = Course(
                              id: course.id,
                              code: course.code,
                              title:
                                  titleController.text.trim(),
                              credits: int.parse(
                                creditsController.text.trim(),
                              ),
                              status: selectedStatus,
                              createdAt: course.createdAt,
                            );

                            await repository
                                .updateCourse(updatedCourse);

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);

                            await refreshCourses();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Mata kuliah berhasil diperbarui.',
                                ),
                              ),
                            );
                          } catch (error) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            if (!dialogContext.mounted) return;

                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal mengedit mata kuliah: $error',
                                ),
                              ),
                            );
                          }
                        },
                  child: Text(
                    isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    creditsController.dispose();
  }

  // DELETE: Meminta konfirmasi sebelum menghapus mata kuliah.
  Future<void> confirmDeleteCourse(Course course) async {
    if (course.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID mata kuliah tidak ditemukan.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Mata Kuliah?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
            '"${course.title}" (${course.code})?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await repository.deleteCourse(course.id!);

      if (!mounted) return;

      await refreshCourses();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mata kuliah "${course.title}" berhasil dihapus.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus mata kuliah: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'Refresh data',
            onPressed: isLoading ? null : refreshCourses,
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
          // Identitas mahasiswa.
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Identitas Mahasiswa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Nama: $studentName'),
                Text('NIM: $studentId'),
              ],
            ),
          ),

          // Judul daftar mata kuliah.
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

          // Isi daftar.
          Expanded(
            child: _buildCourseContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                'Gagal memuat data mata kuliah.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: refreshCourses,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (courses.isEmpty) {
      return RefreshIndicator(
        onRefresh: refreshCourses,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Center(
              child: Text('Belum ada mata kuliah.'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshCourses,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 90,
        ),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${course.credits}'),
              ),
              title: Text(
                course.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kode: ${course.code}'),
                    Text('SKS: ${course.credits}'),
                    Text('Status: ${course.status}'),
                  ],
                ),
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit course',
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.indigo,
                    ),
                    onPressed: () {
                      showEditCourseForm(course);
                    },
                  ),
                  IconButton(
                    tooltip: 'Hapus course',
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      confirmDeleteCourse(course);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}