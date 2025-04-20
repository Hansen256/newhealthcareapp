// appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:healthapp/models/appointment_model.dart';
import 'package:healthapp/services/appointment_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _reminder = false;

  List<Appointment> _appointments = [];
  final AppointmentService _appointmentService = AppointmentService();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    tz.initializeTimeZones();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _loadAppointments();
  }

  Future<void> _initializeNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _scheduleNotification(
      String title, DateTime scheduledDate) async {
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'appointment_channel_id',
      'Appointments',
      channelDescription: 'Appointment reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledDate.hashCode,
      'Appointment Reminder',
      title,
      tzScheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> _cancelNotification(DateTime scheduledDate) async {
    await flutterLocalNotificationsPlugin.cancel(scheduledDate.hashCode);
  }

  Future<void> _loadAppointments() async {
    final data = await _appointmentService.getAppointments();
    setState(() => _appointments = data);
  }

  Future<void> _addAppointment(String title, String description, bool reminder,
      DateTime dateTime) async {
    final newAppointment = Appointment(
      id: '',
      title: title,
      description: description,
      reminder: reminder,
      dateTime: dateTime,
    );
    await _appointmentService.addAppointment(newAppointment);
    await _loadAppointments();
    if (reminder) {
      await _scheduleNotification(title, dateTime);
    }
  }

  Future<void> _removeAppointment(String id, DateTime dateTime) async {
    await _appointmentService.deleteAppointment(id);
    await _loadAppointments();
    await _cancelNotification(dateTime);
  }

  Future<void> _toggleReminder(Appointment appointment) async {
    final updated = appointment.copyWith(reminder: !appointment.reminder);
    await _appointmentService.updateAppointment(updated);
    await _loadAppointments();
    if (updated.reminder) {
      await _scheduleNotification(updated.title, updated.dateTime);
    } else {
      await _cancelNotification(updated.dateTime);
    }
  }

  void _showReminderDialog(Appointment appointment) {
    bool localReminder = appointment.reminder;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Reminder'),
        content: SwitchListTile(
          title: const Text('Enable Reminder'),
          value: localReminder,
          onChanged: (value) {
            setState(() => localReminder = value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = appointment.copyWith(reminder: localReminder);
              await _appointmentService.updateAppointment(updated);
              await _loadAppointments();
              if (updated.reminder) {
                await _scheduleNotification(updated.title, updated.dateTime);
              } else {
                await _cancelNotification(updated.dateTime);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Appointment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Set Reminder'),
                value: _reminder,
                onChanged: (value) => setState(() => _reminder = value),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickDateTime,
                child: const Text('Pick Date & Time'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text.trim();
              final description = _descriptionController.text.trim();

              if (title.isNotEmpty &&
                  description.isNotEmpty &&
                  _selectedDate != null &&
                  _selectedTime != null) {
                final dateTime = DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                  _selectedTime!.hour,
                  _selectedTime!.minute,
                );
                _addAppointment(title, description, _reminder, dateTime);
              }

              _clearForm();
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _reminder = false;
    _selectedDate = null;
    _selectedTime = null;
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final formattedTime =
        DateFormat('EEE, MMM d • h:mm a').format(appointment.dateTime);
    return GestureDetector(
      onLongPress: () => _showReminderDialog(appointment),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: ListTile(
          title: Text(
            appointment.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${appointment.description}\n$formattedTime'),
          isThreeLine: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: appointment.reminder,
                onChanged: (_) => _toggleReminder(appointment),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    _removeAppointment(appointment.id, appointment.dateTime),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Appointments'),
        ),
        body: _appointments.isEmpty
            ? const Center(child: Text('No appointments yet.'))
            : ListView.builder(
                itemCount: _appointments.length,
                itemBuilder: (context, index) {
                  return _buildAppointmentCard(_appointments[index]);
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddAppointmentDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
