import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class MedicationTrackerScreen extends StatefulWidget {
  const MedicationTrackerScreen({super.key});

  @override
  State<MedicationTrackerScreen> createState() =>
      _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState extends State<MedicationTrackerScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> _medications = [];
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadMedications();
    _initNotifications();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _scheduleNotification(
      String medName, String time, int id) async {
    final parts = time.split(RegExp(r'[: ]'));
    if (parts.length < 3) return;

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    final isPM = parts[2].toLowerCase() == 'pm';
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final tz.TZDateTime tzScheduled =
        tz.TZDateTime.from(scheduledTime, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      'Medication Reminder',
      'Time to take $medName',
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_channel_id',
          'Medication Reminders',
          channelDescription: 'Reminders to take your medications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> _cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> _loadMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString('medications');
    if (stored != null) {
      setState(() {
        _medications = List<Map<String, String>>.from(
          json.decode(stored).map((item) => Map<String, String>.from(item)),
        );
      });
    }
  }

  Future<void> _saveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('medications', json.encode(_medications));
  }

  void _addMedication(String name, String time) {
    setState(() {
      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      _medications.add({'name': name, 'time': time, 'id': id.toString()});
      _saveMedications();
      _animationController.forward(from: 0);
      _scheduleNotification(name, time, id);
    });
  }

  void _deleteMedication(int index) {
    final med = _medications[index];
    final id = int.tryParse(med['id'] ?? '');
    if (id != null) _cancelNotification(id);

    setState(() {
      _medications.removeAt(index);
      _saveMedications();
    });
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Medication Name'),
            ),
            TextField(
              controller: timeController,
              decoration:
                  const InputDecoration(labelText: 'Time (e.g. 8:00 AM)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  timeController.text.isNotEmpty) {
                _addMedication(nameController.text, timeController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medication Tracker')),
      body: _medications.isEmpty
          ? const Center(child: Text('No medications added yet.'))
          : ListView.builder(
              itemCount: _medications.length,
              itemBuilder: (context, index) {
                final med = _medications[index];
                return SlideTransition(
                  position: _slideAnimation,
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.medication),
                      title: Text(med['name'] ?? ''),
                      subtitle: Text('Time: ${med['time']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMedication(index),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Medication'),
      ),
    );
  }
}
