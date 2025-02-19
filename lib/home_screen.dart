import 'package:flutter/material.dart';
import 'theme.dart';

class HomeScreen extends StatelessWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            child: Column(
              children: [
                Text(
                  'Bienvenido, $userName',
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona una sección para continuar:',
                  style: TextStyle(color: Colors.white70, fontSize: 16.0),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 800 ? 5 : 2;
                return GridView.count(
                  padding: const EdgeInsets.all(16.0),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildMenuCard(
                      context,
                      title: 'Estudiantes',
                      icon: Icons.person,
                      color: Colors.teal,
                      route: '/students',
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Maestros',
                      icon: Icons.person_outline,
                      color: Colors.blue,
                      route: '/teachers',
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Cursos',
                      icon: Icons.school,
                      color: Colors.orange,
                      route: '/courses',
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Gestión',
                      icon: Icons.settings,
                      color: Colors.grey,
                      route: '/management',
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Cerrar Sesión',
                      icon: Icons.logout,
                      color: Colors.red,
                      route: '/login',
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            color: AppTheme.primaryColor,
            child: const Text(
              '\u00A9 2025 - Gestión de Estudiantes',
              style: TextStyle(color: Colors.white, fontSize: 12.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 4.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50.0, color: Colors.white),
            const SizedBox(height: 10.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
