import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';

class CourseApiService {
  static const String apiUrl =
      'https://jsonplaceholder.typicode.com/posts';

  // GET: Mengambil daftar course
  Future<List<Course>> fetchCourses() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList =
          jsonDecode(response.body) as List<dynamic>;

      return jsonList.map((item) {
        return Course.fromJson(
          item as Map<String, dynamic>,
        );
      }).toList();
    }

    throw Exception(
      'Gagal mengambil data: ${response.statusCode}',
    );
  }

  // POST: Menambahkan course
  Future<Course> createCourse(Course course) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Course.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Gagal membuat course: ${response.statusCode}',
    );
  }

  // PUT: Memperbarui course
  Future<void> updateCourse(int id, Course course) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Gagal memperbarui course: ${response.statusCode}',
      );
    }
  }

  // DELETE: Menghapus course
  Future<void> deleteCourse(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Gagal menghapus course: ${response.statusCode}',
      );
    }
  }
}