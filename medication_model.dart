// lib/models/medication_model.dart

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startTime;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startTime,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      startTime: DateTime.parse(json['startTime']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'startTime': startTime.toIso8601String(),
      };
}
