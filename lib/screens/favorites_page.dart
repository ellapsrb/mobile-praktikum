import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../course_state.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import 'detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseState>();
    final courseProvider = context.watch<CourseProvider>();

    final favoriteCourses = courseProvider.courses
        .where((course) => courseState.isFavorite(course.code))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mata Kuliah Favorit')),
      body: courseProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : courseProvider.error != null
          ? Center(child: Text('Gagal memuat data: ${courseProvider.error}'))
          : favoriteCourses.isEmpty
          ? const Center(child: Text('Belum ada mata kuliah favorit.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteCourses.length,
              itemBuilder: (context, index) {
                final Course course = favoriteCourses[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.favorite, color: Colors.red),
                    title: Text(course.title),
                    subtitle: Text(
                      'Kode: ${course.code} | SKS: ${course.credits}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        context.read<CourseState>().toggleFavorite(course.code);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(course: course),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
