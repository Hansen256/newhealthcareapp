import 'package:flutter/material.dart';
import 'package:healthapp/features/appointments/appointments_screen.dart';
import 'package:healthapp/features/medications/medications_screen.dart';
// ignore: unused_import
import 'package:healthapp/features/records/records_screen.dart';
import 'package:healthapp/features/profile/profile_screen.dart';
import 'package:healthapp/features/symptom checker/symptom_checker_screen.dart'; // <-- ADDED

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare App'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedButton(
                icon: Icons.calendar_today,
                label: "View Appointments",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppointmentsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              AnimatedButton(
                icon: Icons.medication,
                label: "Medication Tracker",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicationTrackerScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              AnimatedButton(
                icon: Icons.psychology, // <-- Icon representing symptom checker
                label: "Symptom Checker", // <-- NEW BUTTON
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SymptomCheckerScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              AnimatedButton(
                icon: Icons.person,
                label: "View Profile",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Animated Button Widget
class AnimatedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const AnimatedButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
