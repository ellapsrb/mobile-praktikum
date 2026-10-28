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

  // INSERT: Menambahkan course baru
  Future<void> createCourse(Course course) async {
    await _supabase
        .from('courses')
        .insert(course.toJson());
  }
}