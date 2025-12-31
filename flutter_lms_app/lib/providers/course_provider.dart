import 'package:flutter/material.dart';

class CourseProvider with ChangeNotifier {
  List<dynamic> _courses = [];

  List<dynamic> get courses => _courses;

  Future<void> fetchCourses() async {
    // Implement fetch courses from API
    // _courses = fetchedCourses;
    notifyListeners();
  }

  Future<void> enrollInCourse(int courseId) async {
    // Implement enrollment
    notifyListeners();
  }
}