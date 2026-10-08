import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/core/network/network_info.dart';
import 'package:learning_dashboard/features/courses/data/course_dto.dart';
import 'package:learning_dashboard/features/courses/domain/course.dart';

abstract interface class CourseApi {
  Future<List<Course>> fetchCourses();

  Future<void> markLessonCompleted({
    required int courseId,
    required int lessonId,
  });
}

class MockCourseApi implements CourseApi {
  MockCourseApi({
    required this._networkInfo,
    AssetBundle? bundle,
    this.latency = const Duration(milliseconds: 800),
  }) : _bundle = bundle ?? rootBundle;

  static const _coursesAsset = 'assets/mock/courses.json';

  final NetworkInfo _networkInfo;
  final AssetBundle _bundle;
  final Duration latency;

  @override
  Future<List<Course>> fetchCourses() async {
    await _simulateRequest();
    final raw = await _bundle.loadString(_coursesAsset, cache: false);
    return CourseDto.listFromJson(jsonDecode(raw));
  }

  @override
  Future<void> markLessonCompleted({
    required int courseId,
    required int lessonId,
  }) async {
    await _simulateRequest();
  }

  Future<void> _simulateRequest() async {
    if (!await _networkInfo.isConnected) {
      throw const NetworkException();
    }
    await Future<void>.delayed(latency);
  }
}
