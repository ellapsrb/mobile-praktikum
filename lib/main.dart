import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/course.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';
import 'services/profile_service.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// ==================== ROLE GUARD ====================

class RoleGuard extends StatelessWidget {
  const RoleGuard({
    super.key,
    required this.role,
    required this.allowed,
    required this.child,
  });

  final String role;
  final List<String> allowed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return allowed.contains(role) ? child : const SizedBox.shrink();
  }
}

// ==================== COURSE PAGE ====================

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final CourseRepository repository = CourseRepository(CourseService());
  final ProfileService profileService = ProfileService();

  List<Course> courses = [];
  Map<String, dynamic>? profile;

  bool isLoading = true;
  bool isProfileLoading = true;
  String? errorMessage;

  final String studentName = 'Tina Ellina Wati';
  final String studentId = '2415051043';

  String get userRole => profile?['role']?.toString() ?? 'seeker';

  bool get canManageCourses => userRole == 'owner' || userRole == 'admin';

  @override
  void initState() {
    super.initState();
    refreshCourses();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final result = await profileService.getMyProfile();

      if (!mounted) return;

      setState(() {
        profile = result;
        isProfileLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isProfileLoading = false;
      });

      debugPrint('Gagal mengambil profil: $error');
    }
  }

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

  // CREATE & UPDATE
  Future<void> showCourseForm({Course? course}) async {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: course?.code ?? '');
    final titleController = TextEditingController(text: course?.title ?? '');
    final creditsController = TextEditingController(
      text: course?.credits.toString() ?? '',
    );

    String selectedStatus = course?.status ?? 'planned';
    bool isSaving = false;
    final isEditing = course != null;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Mata Kuliah' : 'Tambah Mata Kuliah',
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: codeController,
                        readOnly: isEditing,
                        decoration: const InputDecoration(
                          labelText: 'Kode Mata Kuliah',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Kode wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Mata Kuliah',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Nama mata kuliah wajib diisi'
                            : null,
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
                          final credits = int.tryParse(value ?? '');
                          return credits == null || credits < 1
                              ? 'Masukkan jumlah SKS yang valid'
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
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
                          DropdownMenuItem(value: 'done', child: Text('Done')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedStatus = value);
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
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => isSaving = true);

                          try {
                            if (isEditing) {
                              final updatedCourse = Course(
                                id: course.id,
                                code: course.code,
                                title: titleController.text.trim(),
                                credits: int.parse(
                                  creditsController.text.trim(),
                                ),
                                status: selectedStatus,
                                createdAt: course.createdAt,
                              );

                              await repository.updateCourse(updatedCourse);
                            } else {
                              final newCourse = Course(
                                code: codeController.text.trim().toUpperCase(),
                                title: titleController.text.trim(),
                                credits: int.parse(
                                  creditsController.text.trim(),
                                ),
                                status: selectedStatus,
                              );

                              await repository.createCourse(newCourse);
                            }

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            await refreshCourses();

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEditing
                                      ? 'Mata kuliah berhasil diperbarui.'
                                      : 'Mata kuliah berhasil ditambahkan.',
                                ),
                              ),
                            );
                          } catch (error) {
                            setDialogState(() => isSaving = false);

                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text('Gagal: $error')),
                            );
                          }
                        },
                  child: Text(isSaving ? 'Menyimpan...' : 'Simpan'),
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

  // DELETE
  Future<void> confirmDeleteCourse(Course course) async {
    if (course.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Mata Kuliah?'),
        content: Text('Yakin ingin menghapus "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await repository.deleteCourse(course.id!);
      await refreshCourses();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mata kuliah berhasil dihapus.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus mata kuliah: $error')),
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
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      // Tambah Course hanya untuk Owner dan Admin.
      floatingActionButton: RoleGuard(
        role: userRole,
        allowed: const ['owner', 'admin'],
        child: FloatingActionButton.extended(
          onPressed: () => showCourseForm(),
          icon: const Icon(Icons.add),
          label: const Text('Tambah Course'),
        ),
      ),

      body: Column(
        children: [
          // PROFILE
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profil Pengguna',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (isProfileLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  Text('Nama: ${profile?['name'] ?? studentName}'),
                  Text('Email: ${profile?['email'] ?? '-'}'),
                  Text('NIM: $studentId'),
                  Text('Role: $userRole'),
                ],
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daftar Mata Kuliah',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Expanded(child: _buildCourseContent()),
        ],
      ),
    );
  }

  Widget _buildCourseContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              const Text('Gagal memuat data mata kuliah.'),
              const SizedBox(height: 8),
              Text(errorMessage!, textAlign: TextAlign.center),
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
            Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Center(child: Text('Belum ada mata kuliah.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshCourses,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 90),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Text('${course.credits}')),
              title: Text(
                course.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
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

              // Tombol Edit dan Hapus hanya untuk Owner/Admin.
              trailing: RoleGuard(
                role: userRole,
                allowed: const ['owner', 'admin'],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit course',
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.indigo,
                      ),
                      onPressed: () => showCourseForm(course: course),
                    ),
                    IconButton(
                      tooltip: 'Hapus course',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => confirmDeleteCourse(course),
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

// ==================== AUTH GATE ====================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (supabase.auth.currentSession != null) {
          return const CoursePage();
        }
        return const LoginPage();
      },
    );
  }
}

// ==================== LOGIN & REGISTER ====================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _showRegister = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal. Periksa koneksi internet.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.session != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registrasi berhasil!')));
      } else {
        setState(() => _showRegister = false);
        _passwordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registrasi berhasil. Silakan cek email untuk konfirmasi, lalu login.',
            ),
          ),
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi gagal. Periksa koneksi internet.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_showRegister ? 'Register' : 'Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  _showRegister ? Icons.person_add_alt_1 : Icons.lock_open,
                  size: 72,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 16),
                Text(
                  _showRegister ? 'Buat Akun Baru' : 'Selamat Datang',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!value.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password wajib diisi';
                    }
                    if (_showRegister && value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading
                      ? null
                      : _showRegister
                      ? _register
                      : _login,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_showRegister ? 'Register' : 'Login'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          setState(() {
                            _showRegister = !_showRegister;
                            _formKey.currentState?.reset();
                            _passwordController.clear();
                          });
                        },
                  child: Text(
                    _showRegister
                        ? 'Sudah punya akun? Login'
                        : 'Belum punya akun? Register',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
