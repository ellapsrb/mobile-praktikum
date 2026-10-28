import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await repository.getCourses();
    } catch (e) {
      _errorMessage = 'Gagal memuat data mata kuliah: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCourse(Course course) async {
    try {
      await repository.createCourse(course);
      await loadCourses();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan mata kuliah: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourse(Course course) async {
    try {
      await repository.updateCourse(course);
      await loadCourses();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengubah mata kuliah: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourse(int id) async {
    try {
      await repository.deleteCourse(id);
      await loadCourses();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus mata kuliah: $e';
      notifyListeners();
      return false;
    }
  }
}