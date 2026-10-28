import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';

class CourseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // READ: mengambil data course
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

  // INSERT: menambahkan course
  Future<void> createCourse(Course course) async {
    await _supabase.from('courses').insert(course.toJson());
  }

  // UPDATE: mengubah course berdasarkan id
  Future<void> updateCourse(Course course) async {
    if (course.id == null) {
      throw Exception('ID course tidak ditemukan.');
    }

    await _supabase
        .from('courses')
        .update(course.toJson())
        .eq('id', course.id!);
  }
}