import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  CourseRepository(this.apiService);

  final CourseApiService apiService;

  // GET: Mengambil semua course
  Future<List<Course>> getCourses() {
    return apiService.fetchCourses();
  }

  // POST: Menambahkan course
  Future<Course> createCourse(Course course) {
    return apiService.createCourse(course);
  }

  // PUT: Memperbarui course
  Future<void> updateCourse(int id, Course course) {
    return apiService.updateCourse(id, course);
  }

  // DELETE: Menghapus course
  Future<void> deleteCourse(int id) {
    return apiService.deleteCourse(id);
  }
}
