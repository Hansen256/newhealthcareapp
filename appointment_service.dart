import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthapp/models/appointment_model.dart';
import 'package:healthapp/services/notification_service.dart'; // Handles notifications for reminders

/// Service to manage appointments in Firestore and handle notifications.
class AppointmentService {
  final bool
      usePerUserMode; // Determines whether appointments are stored per user or globally.
  final String uid; // The current user's UID, or 'guest' if not authenticated.

  /// Constructor to initialize the service.
  /// If `usePerUserMode` is true, appointments are stored under the user's document.
  AppointmentService({this.usePerUserMode = true})
      : uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  /// Returns the Firestore collection reference for appointments.
  /// If `usePerUserMode` is true, it uses a per-user collection structure.
  CollectionReference get _appointmentCollection {
    if (usePerUserMode) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('appointments');
    } else {
      return FirebaseFirestore.instance.collection('appointments');
    }
  }

  /// Fetches all appointments from Firestore, ordered by `dateTime`.
  Future<List<Appointment>> getAppointments() async {
    final snapshot = await _appointmentCollection.orderBy('dateTime').get();
    return snapshot.docs.map((doc) {
      return Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Streams real-time updates of appointments from Firestore, ordered by `dateTime`.
  Stream<List<Appointment>> streamAppointments() {
    return _appointmentCollection
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Adds a new appointment to Firestore.
  /// If the appointment has a reminder, schedules a notification.
  Future<void> addAppointment(Appointment appointment) async {
    final docRef = await _appointmentCollection.add(appointment.toMap());

    if (appointment.reminder) {
      final notificationId = _generateNotificationId(docRef.id);
      await NotificationService.scheduleNotification(
        id: notificationId,
        title: 'Appointment Reminder',
        body: appointment.title,
        scheduledDate: appointment.dateTime,
      );
    }
  }

  /// Updates an existing appointment in Firestore.
  /// Cancels any existing notification and reschedules it if the reminder is enabled.
  Future<void> updateAppointment(Appointment appointment) async {
    await _appointmentCollection
        .doc(appointment.id)
        .update(appointment.toMap());

    final notificationId = _generateNotificationId(appointment.id);
    await NotificationService.cancelNotification(notificationId);

    if (appointment.reminder) {
      await NotificationService.scheduleNotification(
        id: notificationId,
        title: 'Updated Appointment',
        body: appointment.title,
        scheduledDate: appointment.dateTime,
      );
    }
  }

  /// Deletes an appointment from Firestore.
  /// Cancels any associated notification.
  Future<void> deleteAppointment(String id) async {
    await _appointmentCollection.doc(id).delete();
    await NotificationService.cancelNotification(_generateNotificationId(id));
  }

  /// Generates a unique notification ID based on the appointment ID.
  int _generateNotificationId(String id) {
    return id.hashCode;
  }
}

// This service handles the CRUD operations for appointments in Firestore.
// It also manages notifications for appointment reminders using the NotificationService.
// The `usePerUserMode` flag determines whether to use a per-user collection structure or a global one.
