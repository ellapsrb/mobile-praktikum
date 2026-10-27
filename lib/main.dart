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

  void muatUlangData() {
    setState(() {
      coursesFuture = apiService.fetchCourses();
    });
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
                    // Identitas mahasiswa
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
                                        'Materi Pembelajaran $nomor';

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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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