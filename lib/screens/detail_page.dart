
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../course_state.dart';
import '../models/course.dart';

const String studentName = 'Tina Ellina Wati';
const String studentId = '2415051043';

class DetailPage extends StatelessWidget {
  final Course course;

  const DetailPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseState>();
    final isFavorite = courseState.isFavorite(course.code);

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
              const SizedBox(height: 16),
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
            ],
          ),
        ),
      ),
    );
  }
}
