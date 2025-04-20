import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool reminder;

  Appointment({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.reminder,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime), // Store as Firestore Timestamp
      'reminder': reminder,
    };
  }

  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    final dynamic rawDate = map['dateTime'];

    return Appointment(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: rawDate is Timestamp
          ? rawDate.toDate()
          : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
      reminder: map['reminder'] ?? false,
    );
  }

  // Add the copyWith method
  Appointment copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? reminder,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      reminder: reminder ?? this.reminder,
    );
  }
}
