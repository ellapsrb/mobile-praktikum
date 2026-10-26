import 'dart:convert';
import 'package:http/http.dart' as http;

class CourseApiService {
  static const String apiUrl =
      'https://jsonplaceholder.typicode.com/posts';

  Future<List<dynamic>> fetchCourses() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Gagal mengambil data: ${response.statusCode}',
      );
    }
  }
}