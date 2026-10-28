import '../models/course.dart';
import '../services/course_service.dart';

class CourseRepository {
  CourseRepository(this.courseService);

  final CourseService courseService;

  // GET
  Future<List<Course>> getCourses() {
    return courseService.loadCourses();
  }

  // INSERT
  Future<void> createCourse(Course course) {
    return courseService.createCourse(course);
  }
}
