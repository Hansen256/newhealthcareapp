import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> _records = [];
  late AnimationController _fadeController;
  late String _uid;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      _uid = user.uid;
      _loadRecords();
    } else {
      // Handle auth failure (you can redirect or show a message)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
    }
  }

  Future<void> _loadRecords() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('healthRecords')
        .get();

    setState(() {
      _records = snapshot.docs
          .map((doc) => {
                'name': doc['name']?.toString() ?? '',
                'path': doc['path']?.toString() ?? '',
                'id': doc.id.toString(),
              })
          .toList();
    });
  }

  Future<void> _addRecord() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final name = result.files.single.name;

      final docRef = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('healthRecords')
          .add({'name': name, 'path': path});

      setState(() {
        _records.add({'name': name, 'path': path, 'id': docRef.id});
      });
    }
  }

  Future<void> _deleteRecord(int index) async {
    final record = _records[index];
    final recordId = record['id'];

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('healthRecords')
        .doc(recordId)
        .delete();

    setState(() {
      _records.removeAt(index);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Records')),
      body: _records.isEmpty
          ? const Center(child: Text("No records uploaded yet."))
          : FadeTransition(
              opacity: _fadeController,
              child: ListView.builder(
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  final record = _records[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(Icons.folder_copy),
                      title: Text(record['name'] ?? ''),
                      subtitle: Text(record['path'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRecord(index),
                      ),
                      onTap: () {
                        // You can implement file opening logic later
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        label: const Text("Upload"),
        icon: const Icon(Icons.upload_file),
      ),
    );
  }
}
