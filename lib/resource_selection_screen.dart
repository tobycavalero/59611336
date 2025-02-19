import 'package:flutter/material.dart';

class ResourceSelectionScreen extends StatelessWidget {
  const ResourceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Recurso'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResourceButton(
              context,
              label: 'Estudiantes',
              icon: Icons.person,
              color: Colors.orange,
              route: '/studentList',
            ),
            _buildResourceButton(
              context,
              label: 'Maestros',
              icon: Icons.school,
              color: Colors.green,
              route: '/teacherList', // Asegúrate de tener esta ruta configurada
            ),
            _buildResourceButton(
              context,
              label: 'Clases',
              icon: Icons.class_,
              color: Colors.blue,
              route: '/classList', // Asegúrate de tener esta ruta configurada
            ),
            _buildResourceButton(
              context,
              label: 'Cursos',
              icon: Icons.book,
              color: Colors.purple,
              route: '/courseList', // Asegúrate de tener esta ruta configurada
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required String route}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
