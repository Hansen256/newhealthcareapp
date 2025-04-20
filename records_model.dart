// Health Record Model
class HealthRecord {
  final String id;
  final String title;
  final String filePath; // Local path to file
  final DateTime uploadedAt;
  final String category; // e.g., "X-Ray", "Prescription", etc.

  HealthRecord({
    required this.id,
    required this.title,
    required this.filePath,
    required this.uploadedAt,
    required this.category,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      title: json['title'],
      filePath: json['filePath'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'filePath': filePath,
        'uploadedAt': uploadedAt.toIso8601String(),
        'category': category,
      };
}
