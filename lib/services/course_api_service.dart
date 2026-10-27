import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';

class CourseApiService {
  static const String apiUrl =
      'https://jsonplaceholder.typicode.com/posts';

  // Mengambil daftar course menggunakan HTTP GET.
  Future<List<Course>> fetchCourses() async {
    final response = await http.get(
      Uri.parse(apiUrl),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList =
          jsonDecode(response.body) as List<dynamic>;

      return jsonList.map((item) {
        return Course.fromJson(
          item as Map<String, dynamic>,
        );
      }).toList();
    } else {
      throw Exception(
        'Gagal mengambil data: ${response.statusCode}',
      );
    }
  }

  // Membuat course baru menggunakan HTTP POST.
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
      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;

      return Course.fromJson(jsonResponse);
    } else {
      throw Exception(
        'Gagal membuat course: ${response.statusCode}',
      );
    }
  }
}