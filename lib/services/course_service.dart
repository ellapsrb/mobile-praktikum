import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';

class CourseService {
  final SupabaseClient _supabase = Supabase.instance.client;

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
}