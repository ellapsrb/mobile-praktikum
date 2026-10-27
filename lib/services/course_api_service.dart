import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';

class CourseApiService {
  static const String apiUrl =
      'https://jsonplaceholder.typicode.com/posts';

  Future<List<Course>> fetchCourses() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList =
          jsonDecode(response.body) as List<dynamic>;

      return jsonList.map((item) {
        return Course.fromJson(item as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception(
        'Gagal mengambil data: ${response.statusCode}',
      );
    }
  }
}