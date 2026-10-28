import '../models/course.dart';
import '../services/course_service.dart';

class CourseRepository {
  CourseRepository(this.courseService);

  final CourseService courseService;

  Future<List<Course>> getCourses() {
    return courseService.loadCourses();
  }

  Future<void> createCourse(Course course) {
    return courseService.createCourse(course);
  }

  Future<void> updateCourse(Course course) {
    return courseService.updateCourse(course);
  }
}