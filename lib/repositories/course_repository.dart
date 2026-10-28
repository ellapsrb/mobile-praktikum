import '../models/course.dart';
import '../services/course_service.dart';

class CourseRepository {
  CourseRepository(this.courseService);

  final CourseService courseService;

  // READ
  Future<List<Course>> getCourses() {
    return courseService.loadCourses();
  }

  // INSERT
  Future<void> createCourse(Course course) {
    return courseService.createCourse(course);
  }

  // UPDATE
  Future<void> updateCourse(Course course) {
    return courseService.updateCourse(course);
  }

  // DELETE
  Future<void> deleteCourse(int id) {
    return courseService.deleteCourse(id);
  }
}