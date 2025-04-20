import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthapp/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final String uid;

  ProfileService() : uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  DocumentReference get _profileDoc => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('data')
      .doc('profile');

  Future<void> saveProfile(Profile profile) async {
    await _profileDoc.set(profile.toJson());
  }

  Future<Profile?> fetchProfile() async {
    final docSnapshot = await _profileDoc.get();
    if (docSnapshot.exists) {
      return Profile.fromJson(docSnapshot.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<Profile?> streamProfile() {
    return _profileDoc.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Profile.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<void> deleteProfile() async {
    await _profileDoc.delete();
  }

  // ✅ FIXED: Define getProfile properly
  Future<Profile?> getProfile() => fetchProfile();

  // ✅ FIXED: Add updateProfile
  Future<void> updateProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', profile.name);
    await prefs.setInt('age', profile.age);
    await prefs.setString('email', profile.email);
    await prefs.setString('gender', profile.gender);
    await prefs.setString('phone', profile.phone);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(uid)
          .set(profile.toMap());
    }
  }
}
