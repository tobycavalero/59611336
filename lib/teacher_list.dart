import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'teacher_form.dart';
import 'teacher_profile_screen.dart';
import 'teacher.dart';

class TeacherList extends StatefulWidget {
  const TeacherList({super.key});

  @override
  _TeacherListState createState() => _TeacherListState();
}

class _TeacherListState extends State<TeacherList> {
  List<Teacher> _teachers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('teachers').get();
      final teachers = snapshot.docs.map((doc) {
        return Teacher.fromMap(doc.data(), doc.id);
      }).toList();

      setState(() {
        _teachers = teachers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Maestros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeacherForm()),
              ).then((_) => _loadTeachers());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _teachers.length,
              itemBuilder: (context, index) {
                final teacher = _teachers[index];
                return ListTile(
                  title: Text('${teacher.firstName} ${teacher.lastName}'),
                  subtitle: Text(teacher.subject ?? 'Materia no asignada'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherProfileScreen(teacher: teacher),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
