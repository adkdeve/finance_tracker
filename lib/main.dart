import 'package:finance_recorder/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const FinanceTrackerApp());

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home:  const DashboardScreen(),
    );
  }
}

