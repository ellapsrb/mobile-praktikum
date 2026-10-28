import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';

class CourseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // GET: Mengambil semua course
  Future<List<Course>> loadCourses() async {
    final data = await _supabase
        .from('courses')
        .select()
        .order('id', ascending: true);

    return (data as List)
        .map(
          (item) => Course.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  // POST: Menambahkan course
  Future<Course> createCourse(Course course) async {
    final data = await _supabase
        .from('courses')
        .insert(course.toJson())
        .select()
        .single();

    return Course.fromJson(data);
  }

  // UPDATE: Memperbarui course
  Future<void> updateCourse(int id, Course course) async {
    await _supabase
        .from('courses')
        .update(course.toJson())
        .eq('id', id);
  }

  // DELETE: Menghapus course
  Future<void> deleteCourse(int id) async {
    await _supabase
        .from('courses')
        .delete()
        .eq('id', id);
  }
}