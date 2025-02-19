import 'package:flutter/material.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión'),
      ),
      body: Center(
        child: const Text('Opciones de Gestión - Placeholder'),
      ),
    );
  }
}
