import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../theme.dart';
import '../widgets/subject_card.dart';
import '../widgets/attendance_ring.dart';
import 'subject_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        if (!provider.loaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final overall = provider.overallAttendance;
        final subjects = provider.subjects;
        final atRisk = subjects.where((s) => !s.isSafe).length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Bunk Tracker'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white54),
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _OverallCard(
                      overall: overall, atRisk: atRisk, total: subjects.length),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'SUBJECTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white38,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final subject = subjects[index];
                    return SubjectCard(
                      subject: subject,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SubjectDetailScreen(subjectId: subject.id),
                        ),
                      ),
                      onPresent: () =>
                          provider.markAttendance(subject.id, true),
                      onAbsent: () =>
                          provider.markAttendance(subject.id, false),
                    );
                  },
                  childCount: subjects.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('How it works',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '• Mark Present/Absent for each class\n'
          '• The app calculates your attendance %\n'
          '• "Can bunk X" = safe bunks before hitting minimum\n'
          '• "Attend X more" = classes needed to reach minimum\n'
          '• Tap a subject to see details and trends\n'
          '• Long-press subject name in detail screen to edit',
          style: TextStyle(color: Colors.white70, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}

class _OverallCard extends StatelessWidget {
  final double overall;
  final int atRisk;
  final int total;
  const _OverallCard(
      {required this.overall, required this.atRisk, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.3),
            AppTheme.card,
          ],
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
            percentage: overall,
            minPercentage: 75,
            size: 100,
            strokeWidth: 10,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overall Attendance',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Across all $total subjects',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                if (atRisk > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '⚠ $atRisk subject${atRisk > 1 ? 's' : ''} at risk',
                      style: const TextStyle(
                          color: AppTheme.danger,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✓ All subjects safe',
                      style: TextStyle(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
