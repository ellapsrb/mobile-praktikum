import '../models/course.dart';
import '../services/course_service.dart';

class CourseRepository {
  CourseRepository(this.courseService);

  final CourseService courseService;

  // GET
  Future<List<Course>> getCourses() {
    return courseService.loadCourses();
  }

  // CREATE
  Future<Course> createCourse(Course course) {
    return courseService.createCourse(course);
  }

  // UPDATE
  Future<void> updateCourse(int id, Course course) {
    return courseService.updateCourse(id, course);
  }

  // DELETE
  Future<void> deleteCourse(int id) {
    return courseService.deleteCourse(id);
  }
}