import 'package:flutter/material.dart';
import 'teacher.dart';

class TeacherProfileScreen extends StatelessWidget {
  final Teacher teacher;

  const TeacherProfileScreen({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Maestro'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text(
                teacher.firstName.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${teacher.firstName} ${teacher.lastName}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              teacher.email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Manejo de null para la asignatura
            if (teacher.subject != null && teacher.subject!.isNotEmpty)
              Text(
                'Materia: ${teacher.subject}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              )
            else
              const Text(
                'Materia no asignada',
                style: TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/teacherForm',
                  arguments: teacher,
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
