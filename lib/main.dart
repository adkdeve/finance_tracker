import 'package:finance_recorder/screens/OnboardingScreen.dart';
import 'package:finance_recorder/screens/dashboard_screen.dart';
import 'package:finance_recorder/screens/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const FinanceTrackerApp());

class FinanceTrackerApp extends StatefulWidget {
  const FinanceTrackerApp({super.key});

  @override
  _FinanceTrackerAppState createState() => _FinanceTrackerAppState();
}

class _FinanceTrackerAppState extends State<FinanceTrackerApp> {
  bool _showOnboarding = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? onboardingComplete = prefs.getBool('onboarding_complete');
    setState(() {
      _showOnboarding = onboardingComplete == null || !onboardingComplete;
      _isLoading = false; // End splash screen loading
    });
  }

  void _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _isLoading
          ? SplashScreen(
        onLoadingComplete: _checkOnboardingStatus, // Ensures splash logic runs first
      )
          : _showOnboarding
          ? OnboardingScreen(
        onCompleted: _completeOnboarding,
      )
          : const DashboardScreen(),
    );
  }
}
