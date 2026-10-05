import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
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
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

// Membaca data dari file JSON
Future<Map<String, dynamic>> loadStudentData() async {
  final String jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );

  final Map<String, dynamic> data = jsonDecode(jsonString);

  return data;
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: loadStudentData(),

        builder: (context, snapshot) {
          // Saat data sedang dibaca
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Jika terjadi error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // Jika data berhasil dibaca
          if (snapshot.hasData) {
            final data = snapshot.data!;

            final student = data['student'];
            final courses = data['courses'];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identitas mahasiswa
                  Text(
                    student['name'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'NIM: ${student['nim']}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Judul
                  const Text(
                    'Daftar Mata Kuliah',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Menampilkan daftar mata kuliah
                  Expanded(
                    child: ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                course['credits'].toString(),
                              ),
                            ),

                            title: Text(
                              course['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Text(
                              '${course['code']} • ${course['credits']} SKS',
                            ),

                            trailing: Text(
                              course['status'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: course['status'] == 'Selesai'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Data tidak tersedia'),
          );
        },
      ),
    );
  }
}