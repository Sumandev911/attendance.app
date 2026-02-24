import 'dart:convert';

class AttendanceRecord {
  final DateTime date;
  final bool isPresent;

  AttendanceRecord({required this.date, required this.isPresent});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'isPresent': isPresent,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        date: DateTime.parse(json['date']),
        isPresent: json['isPresent'],
      );
}

class Subject {
  String id;
  String name;
  double minAttendance; // percentage e.g. 75.0
  List<AttendanceRecord> records;

  Subject({
    required this.id,
    required this.name,
    this.minAttendance = 75.0,
    List<AttendanceRecord>? records,
  }) : records = records ?? [];

  int get totalClasses => records.length;
  int get attendedClasses => records.where((r) => r.isPresent).length;
  int get missedClasses => records.where((r) => !r.isPresent).length;

  double get attendancePercentage =>
      totalClasses == 0 ? 100.0 : (attendedClasses / totalClasses) * 100;

  bool get isSafe => attendancePercentage >= minAttendance;

  /// How many more classes can be bunked while staying >= minAttendance
  int get bunkable {
    if (totalClasses == 0) return 0;
    // attended / (total + x) >= min/100  =>  x <= attended*100/min - total
    final max = (attendedClasses * 100 / minAttendance) - totalClasses;
    return max < 0 ? 0 : max.floor();
  }

  /// How many consecutive classes must be attended to reach minAttendance
  int get classesNeeded {
    if (attendancePercentage >= minAttendance) return 0;
    // (attended + x) / (total + x) >= min/100
    // attended + x >= min/100 * (total + x)
    // x(1 - min/100) >= min/100 * total - attended
    final ratio = minAttendance / 100;
    final needed = (ratio * totalClasses - attendedClasses) / (1 - ratio);
    return needed <= 0 ? 0 : needed.ceil();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'minAttendance': minAttendance,
        'records': records.map((r) => r.toJson()).toList(),
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'],
        name: json['name'],
        minAttendance: (json['minAttendance'] as num).toDouble(),
        records: (json['records'] as List)
            .map((r) => AttendanceRecord.fromJson(r))
            .toList(),
      );

  Subject copyWith({
    String? name,
    double? minAttendance,
    List<AttendanceRecord>? records,
  }) =>
      Subject(
        id: id,
        name: name ?? this.name,
        minAttendance: minAttendance ?? this.minAttendance,
        records: records ?? List.from(this.records),
      );
}
