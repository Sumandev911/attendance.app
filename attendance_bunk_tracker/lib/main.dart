import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/attendance_provider.dart';
import 'screens/dashboard_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AttendanceProvider()..load(),
      child: const BunkTrackerApp(),
    ),
  );
}

class BunkTrackerApp extends StatelessWidget {
  const BunkTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Bunk Tracker',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}
