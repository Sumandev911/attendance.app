import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/attendance_provider.dart';
import '../models/subject.dart';
import '../theme.dart';
import '../widgets/attendance_ring.dart';

class SubjectDetailScreen extends StatelessWidget {
  final String subjectId;
  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        final subject =
            provider.subjects.firstWhere((s) => s.id == subjectId);
        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () => _editName(context, provider, subject),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(subject.name),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit, size: 16, color: Colors.white38),
                ],
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon:
                    const Icon(Icons.more_vert, color: Colors.white54),
                color: AppTheme.card,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'edit_min') {
                    _editMinAttendance(context, provider, subject);
                  } else if (value == 'reset') {
                    _confirmReset(context, provider, subject);
                  } else if (value == 'undo') {
                    provider.undoLast(subject.id);
                  }
                },
                itemBuilder: (_) => [
                  _menuItem('undo', Icons.undo, 'Undo Last Entry'),
                  _menuItem('edit_min', Icons.tune, 'Edit Min Attendance'),
                  _menuItem('reset', Icons.delete_outline, 'Reset Data',
                      isDestructive: true),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatsHeader(subject: subject),
              const SizedBox(height: 20),
              _InfoCards(subject: subject),
              const SizedBox(height: 20),
              if (subject.records.isNotEmpty) ...[
                _TrendChart(subject: subject),
                const SizedBox(height: 20),
              ],
              _RecentHistory(subject: subject, provider: provider),
            ],
          ),
          bottomNavigationBar: _MarkButtons(
            onPresent: () => provider.markAttendance(subject.id, true),
            onAbsent: () => provider.markAttendance(subject.id, false),
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label,
      {bool isDestructive = false}) =>
      PopupMenuItem(
        value: value,
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isDestructive ? AppTheme.danger : Colors.white70),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    color:
                        isDestructive ? AppTheme.danger : Colors.white70)),
          ],
        ),
      );

  void _editName(
      BuildContext context, AttendanceProvider provider, Subject subject) {
    final ctrl = TextEditingController(text: subject.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rename Subject'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Subject name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                provider.renameSubject(subject.id, ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child:
                const Text('Save', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _editMinAttendance(
      BuildContext context, AttendanceProvider provider, Subject subject) {
    final ctrl =
        TextEditingController(text: subject.minAttendance.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Minimum Attendance %'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration:
              const InputDecoration(hintText: 'e.g. 75', suffixText: '%'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim());
              if (val != null && val > 0 && val <= 100) {
                provider.updateMinAttendance(subject.id, val);
              }
              Navigator.pop(context);
            },
            child:
                const Text('Save', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _confirmReset(
      BuildContext context, AttendanceProvider provider, Subject subject) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Subject Data'),
        content: Text(
            'This will delete all ${subject.totalClasses} records for "${subject.name}". This cannot be undone.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              provider.resetSubject(subject.id);
              Navigator.pop(context);
            },
            child: const Text('Reset',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final Subject subject;
  const _StatsHeader({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary.withOpacity(0.2), AppTheme.card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppTheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          AttendanceRing(
            percentage: subject.attendancePercentage,
            minPercentage: subject.minAttendance,
            size: 110,
            strokeWidth: 11,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatRow('Attended', '${subject.attendedClasses}',
                    AppTheme.success),
                const SizedBox(height: 8),
                _StatRow('Missed', '${subject.missedClasses}', AppTheme.danger),
                const SizedBox(height: 8),
                _StatRow('Total', '${subject.totalClasses}', Colors.white70),
                const SizedBox(height: 8),
                _StatRow('Minimum', '${subject.minAttendance.toInt()}%',
                    AppTheme.warning),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _InfoCards extends StatelessWidget {
  final Subject subject;
  const _InfoCards({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!subject.isSafe)
          Expanded(
            child: _InfoCard(
              icon: Icons.warning_amber_rounded,
              label: 'Classes Needed',
              value: '${subject.classesNeeded}',
              color: AppTheme.danger,
            ),
          )
        else
          Expanded(
            child: _InfoCard(
              icon: Icons.celebration_outlined,
              label: 'Can Bunk',
              value: '${subject.bunkable}',
              color: AppTheme.success,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.flag_outlined,
            label: 'Min Required',
            value: '${subject.minAttendance.toInt()}%',
            color: AppTheme.warning,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final Subject subject;
  const _TrendChart({required this.subject});

  @override
  Widget build(BuildContext context) {
    // Build cumulative attendance % over time
    final records = subject.records;
    if (records.length < 2) return const SizedBox.shrink();

    List<FlSpot> spots = [];
    int attended = 0;
    for (int i = 0; i < records.length; i++) {
      if (records[i].isPresent) attended++;
      final pct = (attended / (i + 1)) * 100;
      spots.add(FlSpot(i.toDouble(), pct));
    }

    final minLine = subject.minAttendance;
    final isSafe = subject.isSafe;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attendance Trend',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('${records.length} classes recorded',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white10,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 25,
                      getTitlesWidget: (val, meta) => Text(
                        '${val.toInt()}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval:
                          (records.length / 4).ceilToDouble().clamp(1, 999),
                      getTitlesWidget: (val, meta) => Text(
                        '${val.toInt() + 1}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: minLine,
                      color: AppTheme.warning.withOpacity(0.7),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        labelResolver: (_) => '${minLine.toInt()}% min',
                        style: const TextStyle(
                            color: AppTheme.warning, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: isSafe ? AppTheme.secondary : AppTheme.danger,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: spots.length <= 20,
                      getDotPainter: (spot, pct, bar, idx) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: isSafe ? AppTheme.secondary : AppTheme.danger,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          (isSafe ? AppTheme.secondary : AppTheme.danger)
                              .withOpacity(0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentHistory extends StatelessWidget {
  final Subject subject;
  final AttendanceProvider provider;
  const _RecentHistory(
      {required this.subject, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (subject.records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'No attendance recorded yet.\nTap Present or Absent to start.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, height: 1.6),
          ),
        ),
      );
    }

    final recent = subject.records.reversed.take(30).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent History',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(
                  '${recent.length} of ${subject.totalClasses}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          ...recent.asMap().entries.map((entry) {
            final i = entry.key;
            final record = entry.value;
            final classNum = subject.totalClasses - i;
            return _HistoryTile(
                record: record, classNum: classNum);
          }),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final AttendanceRecord record;
  final int classNum;
  const _HistoryTile({required this.record, required this.classNum});

  @override
  Widget build(BuildContext context) {
    final color =
        record.isPresent ? AppTheme.success : AppTheme.danger;
    final label = record.isPresent ? 'Present' : 'Absent';
    final date = record.date;
    final dateStr =
        '${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text('Class $classNum',
              style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
          const Spacer(),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          const SizedBox(width: 10),
          Text(dateStr,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

class _MarkButtons extends StatelessWidget {
  final VoidCallback onPresent;
  final VoidCallback onAbsent;
  const _MarkButtons(
      {required this.onPresent, required this.onAbsent});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bg,
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onPresent,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark Present'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onAbsent,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Mark Absent'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
