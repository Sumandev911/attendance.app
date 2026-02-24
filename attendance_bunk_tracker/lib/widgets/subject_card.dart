import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../theme.dart';
import '../widgets/attendance_ring.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;
  final VoidCallback onPresent;
  final VoidCallback onAbsent;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
    required this.onPresent,
    required this.onAbsent,
  });

  @override
  Widget build(BuildContext context) {
    final pct = subject.attendancePercentage;
    final isSafe = subject.isSafe;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSafe
                ? Colors.transparent
                : AppTheme.danger.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                AttendanceRing(
                  percentage: pct,
                  minPercentage: subject.minAttendance,
                  size: 80,
                  strokeWidth: 8,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${subject.attendedClasses}/${subject.totalClasses} classes attended',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      _StatusChip(subject: subject),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Present ✓',
                    color: AppTheme.success,
                    onTap: onPresent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'Absent ✗',
                    color: AppTheme.danger,
                    onTap: onAbsent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Subject subject;
  const _StatusChip({required this.subject});

  @override
  Widget build(BuildContext context) {
    if (!subject.isSafe) {
      final needed = subject.classesNeeded;
      return _chip(
        '⚠ Attend $needed more',
        AppTheme.danger,
      );
    }
    final bunkable = subject.bunkable;
    if (bunkable == 0) {
      return _chip('On the edge!', AppTheme.warning);
    }
    return _chip('Can bunk $bunkable', AppTheme.success);
  }

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}
