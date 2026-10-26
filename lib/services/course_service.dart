import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/course.dart';

class CourseService {
  Future<List<Course>> loadCourses() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['courses'] as List<dynamic>;

    return list
        .map(
          (item) => Course.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}