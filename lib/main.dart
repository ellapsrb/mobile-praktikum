import 'package:flutter/material.dart';
import 'models/course.dart';
import 'services/course_api_service.dart';

const String studentName = 'Tina Ellina Wati';
const String studentId = '2415051043';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dasbor Pembelajaran',
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
  final CourseApiService apiService = CourseApiService();

  late Future<List<Course>> coursesFuture;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController =
      TextEditingController();
  final TextEditingController _titleController =
      TextEditingController();
  final TextEditingController _creditsController =
      TextEditingController();

  final Map<int, String> judulIndonesia = {
    1: 'Panduan Membuat Program dan Mengelola Data',
    2: 'Pengenalan Konsep Dasar Pemrograman',
    3: 'Strategi Pemecahan Masalah dalam Pemrograman',
    4: 'Penerapan Teknologi dalam Kehidupan Sehari-hari',
    5: 'Dasar-Dasar Pengembangan Aplikasi',
    6: 'Pengelolaan Data dan Informasi',
    7: 'Pengenalan Sistem Komputer',
    8: 'Dasar-Dasar Jaringan Komputer',
    9: 'Penerapan Algoritma dalam Pemrograman',
    10: 'Pengembangan Sistem Informasi',
  };

  @override
  void initState() {
    super.initState();
    coursesFuture = apiService.fetchCourses();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  void muatUlangData() {
    setState(() {
      coursesFuture = apiService.fetchCourses();
    });
  }

  // Menampilkan form untuk membuat course baru.
  void tampilkanFormCourse() {
    _codeController.clear();
    _titleController.clear();
    _creditsController.clear();
    _formKey.currentState?.reset();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool sedangMenyimpan = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Course'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Kode Course',
                          hintText: 'Contoh: PTI101',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Kode course wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Course',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Judul course wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _creditsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Credits / SKS',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Credits wajib diisi';
                          }

                          final int? credits =
                              int.tryParse(value.trim());

                          if (credits == null) {
                            return 'Credits harus berupa angka bulat';
                          }

                          if (credits <= 0) {
                            return 'Credits harus lebih dari 0';
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
                  onPressed: sedangMenyimpan
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: sedangMenyimpan
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {
                            sedangMenyimpan = true;
                          });

                          final Course course = Course(
                            code: _codeController.text.trim(),
                            title: _titleController.text.trim(),
                            credits: int.parse(
                              _creditsController.text.trim(),
                            ),
                            status: 'active',
                            userId: 1,
                          );

                          try {
                            await apiService.createCourse(course);

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            muatUlangData();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Permintaan POST berhasil dikirim!',
                                ),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              sedangMenyimpan = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal menambahkan course: $e',
                                ),
                              ),
                            );
                          }
                        },
                  child: sedangMenyimpan
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor Pembelajaran'),
        backgroundColor:
            Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: tampilkanFormCourse,
            icon: const Icon(Icons.add),
            tooltip: 'Tambah course',
          ),
          IconButton(
            onPressed: muatUlangData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang data',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool layarLebar = constraints.maxWidth >= 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Identitas mahasiswa.
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: const Icon(
                                Icons.school,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    studentName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('NIM: $studentId'),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Pendidikan Teknik Informatika',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Daftar Data dari REST API',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Data berikut diambil dari server menggunakan '
                      'HTTP GET.',
                    ),
                    const SizedBox(height: 16),

                    // Menampilkan status permintaan GET.
                    FutureBuilder<List<Course>>(
                      future: coursesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Gagal mengambil data dari server.',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: muatUlangData,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final List<Course> courses =
                            snapshot.data ?? <Course>[];

                        if (courses.isEmpty) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'Belum ada data yang tersedia.',
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.cloud_done,
                                  color: Colors.green,
                                  size: 32,
                                ),
                                title: const Text(
                                  'Koneksi ke server berhasil',
                                ),
                                subtitle: Text(
                                  'Jumlah data: ${courses.length}',
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: layarLebar ? 2 : 1,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 135,
                              ),
                              itemCount: courses.length,
                              itemBuilder: (context, index) {
                                final Course course = courses[index];

                                final int nomor =
                                    course.id ?? index + 1;

                                final String judul =
                                    judulIndonesia[nomor] ??
                                        course.title;

                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          child: Text('$nomor'),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Materi $nomor',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Expanded(
                                                child: Text(
                                                  judul,
                                                  maxLines: 3,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                ),
                                              ),
                                              const Text(
                                                'Sumber: REST API',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}