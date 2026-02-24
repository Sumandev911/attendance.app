import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/subject.dart';

const _kSubjectsKey = 'subjects_v1';
const _uuid = Uuid();

class AttendanceProvider extends ChangeNotifier {
  List<Subject> _subjects = [];
  bool _loaded = false;

  List<Subject> get subjects => _subjects;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSubjectsKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _subjects = list.map((e) => Subject.fromJson(e)).toList();
    } else {
      _subjects = _defaultSubjects();
      await _save();
    }
    _loaded = true;
    notifyListeners();
  }

  List<Subject> _defaultSubjects() => [
        'Mathematics',
        'Physics',
        'Chemistry',
        'English',
        'Computer Science',
        'Biology',
        'History',
        'Physical Education',
      ]
          .map((name) => Subject(id: _uuid.v4(), name: name))
          .toList();

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kSubjectsKey, jsonEncode(_subjects.map((s) => s.toJson()).toList()));
  }

  Future<void> markAttendance(String subjectId, bool isPresent) async {
    final idx = _subjects.indexWhere((s) => s.id == subjectId);
    if (idx == -1) return;
    final subject = _subjects[idx];
    final record =
        AttendanceRecord(date: DateTime.now(), isPresent: isPresent);
    _subjects[idx] = subject.copyWith(
        records: [...subject.records, record]);
    notifyListeners();
    await _save();
  }

  Future<void> undoLast(String subjectId) async {
    final idx = _subjects.indexWhere((s) => s.id == subjectId);
    if (idx == -1) return;
    final subject = _subjects[idx];
    if (subject.records.isEmpty) return;
    final newRecords = List<AttendanceRecord>.from(subject.records)
      ..removeLast();
    _subjects[idx] = subject.copyWith(records: newRecords);
    notifyListeners();
    await _save();
  }

  Future<void> renameSubject(String subjectId, String newName) async {
    final idx = _subjects.indexWhere((s) => s.id == subjectId);
    if (idx == -1) return;
    _subjects[idx] = _subjects[idx].copyWith(name: newName);
    notifyListeners();
    await _save();
  }

  Future<void> updateMinAttendance(
      String subjectId, double minAttendance) async {
    final idx = _subjects.indexWhere((s) => s.id == subjectId);
    if (idx == -1) return;
    _subjects[idx] =
        _subjects[idx].copyWith(minAttendance: minAttendance);
    notifyListeners();
    await _save();
  }

  Future<void> resetSubject(String subjectId) async {
    final idx = _subjects.indexWhere((s) => s.id == subjectId);
    if (idx == -1) return;
    _subjects[idx] = _subjects[idx].copyWith(records: []);
    notifyListeners();
    await _save();
  }

  double get overallAttendance {
    if (_subjects.isEmpty) return 0;
    final total = _subjects.fold(0, (sum, s) => sum + s.totalClasses);
    final attended = _subjects.fold(0, (sum, s) => sum + s.attendedClasses);
    if (total == 0) return 100.0;
    return (attended / total) * 100;
  }
}
