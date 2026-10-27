import 'package:flutter/material.dart';
import 'models/course.dart';
import 'services/course_api_service.dart';

void main() {
  runApp(const MyApp());
}

const String studentName = 'Tina Ellina Wati';
const String studentId = '2415051043';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF565DA8),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF7FF),
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

  void tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  // Menerjemahkan beberapa judul bawaan JSONPlaceholder.
  String terjemahkanJudul(String judul) {
    const Map<String, String> terjemahan = {
      'sunt aut facere repellat provident occaecati excepturi optio reprehenderit':
          'Pengantar Pemrograman',
      'qui est esse': 'Dasar-Dasar Teknologi Informasi',
      'ea molestias quasi exercitationem repellat qui ipsa sit aut':
          'Pengembangan Aplikasi',
      'eum et est occaecati': 'Sistem Informasi',
      'nesciunt quas odio': 'Algoritma dan Pemrograman',
      'dolorem eum magni eos aperiam quia':
          'Pengantar Basis Data',
      'magnam facilis autem':
          'Jaringan Komputer',
      'dolorem dolore est ipsam':
          'Pengembangan Perangkat Lunak',
    };

    return terjemahan[judul] ?? judul;
  }

  Future<void> tampilkanFormCourse({Course? course}) async {
    final bool modeEdit = course != null;

    final formKey = GlobalKey<FormState>();
    final kodeController = TextEditingController(
      text: course?.code ?? '',
    );
    final judulController = TextEditingController(
      text: modeEdit
          ? terjemahkanJudul(course.title)
          : '',
    );
    final sksController = TextEditingController(
      text: course != null && course.credits > 0
          ? course.credits.toString()
          : '3',
    );

    final bool? berhasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool sedangMenyimpan = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                modeEdit ? 'Edit Mata Kuliah' : 'Tambah Mata Kuliah',
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: kodeController,
                        decoration: const InputDecoration(
                          labelText: 'Kode Mata Kuliah',
                          hintText: 'Contoh: PTI101',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kode mata kuliah wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: judulController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Mata Kuliah',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama mata kuliah wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: sksController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah SKS',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final sks = int.tryParse(value ?? '');

                          if (sks == null || sks < 1 || sks > 6) {
                            return 'Masukkan SKS antara 1 sampai 6';
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
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: sedangMenyimpan
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          if (modeEdit && course.id == null) {
                            tampilkanPesan(
                              'ID mata kuliah tidak tersedia',
                            );
                            return;
                          }

                          setDialogState(() {
                            sedangMenyimpan = true;
                          });

                          final dataCourse = Course(
                            id: course?.id,
                            userId: course?.userId ?? 1,
                            code: kodeController.text.trim(),
                            title: judulController.text.trim(),
                            credits: int.parse(sksController.text),
                            status: course?.status ?? 'active',
                            body: course?.body ??
                                'Mata kuliah Pendidikan Teknik Informatika',
                          );

                          try {
                            if (modeEdit) {
                              await apiService.updateCourse(
                                course!.id!,
                                dataCourse,
                              );
                            } else {
                              await apiService.createCourse(dataCourse);
                            }

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext, true);
                          } catch (error) {
                            setDialogState(() {
                              sedangMenyimpan = false;
                            });

                            tampilkanPesan(
                              'Gagal menyimpan data. Periksa koneksi API.',
                            );
                          }
                        },
                  child: Text(
                    sedangMenyimpan ? 'Menyimpan...' : 'Simpan',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    kodeController.dispose();
    judulController.dispose();
    sksController.dispose();

    if (!mounted) return;

    if (berhasil == true) {
      muatUlangData();

      tampilkanPesan(
        modeEdit
            ? 'Permintaan perubahan berhasil dikirim'
            : 'Mata kuliah berhasil ditambahkan',
      );
    }
  }

  Widget buildKartuCourse(Course course, int index) {
    final String judul = terjemahkanJudul(course.title);

    // Data tambahan ini hanya untuk tampilan ketika field API kosong.
    final String kode = course.code.trim().isNotEmpty
        ? course.code
        : 'MK-${(index + 1).toString().padLeft(2, '0')}';

    final int sks = course.credits > 0 ? course.credits : 3;

    return Card(
      elevation: 0,
      color: const Color(0xFFF3F0FA),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE3DDEC),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text('Kode: $kode'),
            const SizedBox(height: 4),
            Text('SKS: $sks'),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  tampilkanFormCourse(course: course);
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
        backgroundColor: const Color(0xFFFAF7FF),
        actions: [
          IconButton(
            tooltip: 'Muat ulang data',
            onPressed: muatUlangData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => tampilkanFormCourse(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Course'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              elevation: 0,
              color: const Color(0xFFF3F0FA),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0E2FF),
                  child: Icon(
                    Icons.school,
                    color: Color(0xFF343D78),
                  ),
                ),
                title: const Text(
                  studentName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'NIM: $studentId\n'
                  'Pendidikan Teknik Informatika',
                ),
                isThreeLine: true,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Daftar Mata Kuliah',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Gagal mengambil data mata kuliah.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: muatUlangData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final courses = snapshot.data ?? [];

                  if (courses.isEmpty) {
                    return const Center(
                      child: Text('Belum ada data mata kuliah.'),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final int jumlahKolom =
                          constraints.maxWidth >= 900
                              ? 3
                              : constraints.maxWidth >= 500
                                  ? 2
                                  : 1;

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          12,
                          4,
                          12,
                          90,
                        ),
                        itemCount: courses.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: jumlahKolom,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 190,
                        ),
                        itemBuilder: (context, index) {
                          return buildKartuCourse(
                            courses[index],
                            index,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}