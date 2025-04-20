class Profile {
  final String name;
  final int age;
  final String gender;
  final String email;
  final String phone;
  final String profileImagePath;

  Profile({
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
    required this.profileImagePath,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImagePath: json['profileImagePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'email': email,
        'phone': phone,
        'profileImagePath': profileImagePath,
      };

  // ✅ FIXED: Add copyWith() method
  Profile copyWith({
    String? name,
    int? age,
    String? gender,
    String? email,
    String? phone,
    String? profileImagePath,
  }) {
    return Profile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'email': email,
      'gender': gender,
      'phone': phone,
    };
  }
}
