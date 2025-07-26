import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_recorder/screens/ProfileScreen.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onCompleted;
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  OnboardingScreen({super.key, required this.onCompleted});

  void _onIntroEnd(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('onboarding_complete', true);
    saveUserData();
    onCompleted();
  }
  void saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fName', fNameController.text);
    await prefs.setString('lName', lNameController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('phoneNumber', phoneNumberController.text);
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        // Page 1: Welcome Screen
        PageViewModel(
          titleWidget: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Welcome to EchoWallet",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          bodyWidget: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Reflecting every financial move you make.",
              style: TextStyle(fontSize: 18),
            ),
          ),
          image: const Center(
            child: Icon(
              Icons.account_balance_wallet,
              size: 100,
            ),
          ),
        ),

        // Page 2: Purpose of the App
        PageViewModel(
          title: "Why Use Finance Tracker?",
          body: "Easily track your income and expenses, and get insights into your spending habits.",
          image: const Center(
            child: Icon(
              Icons.pie_chart,
              size: 100,
            ),
          ),
        ),

        // Page 3: User Input for First Name, Last Name, Email, and Phone Number
        PageViewModel(
          titleWidget: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Let's Get to Know You",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          bodyWidget: Column(
            children: [
              TextField(
                controller: fNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  fName = value;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  lName = value;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  phoneNumber = value;
                },
              ),
            ],
          ),
          image: const Center(
            child: Icon(
              Icons.person,
              size: 100,
            ),
          ),
        ),

        // Page 4: All Set
        PageViewModel(
          title: "You're All Set!",
          body: "Let's get started with tracking your finances.",
          image: const Center(
            child: Icon(
              Icons.check_circle,
              size: 100,
            ),
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
