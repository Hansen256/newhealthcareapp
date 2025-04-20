import 'package:flutter/material.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _symptoms = [
    {'icon': Icons.psychology, 'label': 'Headache'},
    {'icon': Icons.sick, 'label': 'Nausea'},
    {'icon': Icons.thermostat, 'label': 'Fever'},
    {'icon': Icons.coronavirus, 'label': 'Cough'},
    {'icon': Icons.air, 'label': 'Shortness of Breath'},
    {'icon': Icons.monitor_heart, 'label': 'Chest Pain'},
    {'icon': Icons.visibility, 'label': 'Blurred Vision'},
    {'icon': Icons.healing, 'label': 'Fatigue'},
  ];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final Map<String, String> _notes = {};
  final Map<String, double> _severity = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSymptomTap(String symptom) {
    String note = _notes[symptom] ?? '';
    double severity = _severity[symptom] ?? 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  symptom,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Add optional notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) => note = value,
                  controller: TextEditingController(text: note),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text("Severity:"),
                    Expanded(
                      child: Slider(
                        min: 1,
                        max: 10,
                        divisions: 9,
                        value: severity,
                        label: severity.toStringAsFixed(0),
                        onChanged: (value) {
                          setState(() => _severity[symptom] = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _notes[symptom] = note;
                      _severity[symptom] = severity;
                    });
                    Navigator.pop(context);
                    _showSummary(symptom);
                  },
                  child: const Text("Save & Analyze"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSummary(String symptom) {
    final severity = _severity[symptom]?.toStringAsFixed(0) ?? 'N/A';
    final note = _notes[symptom] ?? 'No notes provided';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Analysis for $symptom"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Severity Level: $severity/10"),
            const SizedBox(height: 8),
            Text("Notes: $note"),
            const SizedBox(height: 12),
            const Text(
              "Disclaimer: This is a basic assessment. Please consult a healthcare professional for diagnosis.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Symptom Checker'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: _symptoms.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final symptom = _symptoms[index];
              return GestureDetector(
                onTap: () => _onSymptomTap(symptom['label']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(symptom['icon'], size: 40, color: Colors.teal),
                      const SizedBox(height: 12),
                      Text(
                        symptom['label'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
