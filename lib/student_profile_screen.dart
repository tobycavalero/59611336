import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student.dart';

class StudentProfile extends StatefulWidget {
  final Student student;

  const StudentProfile({super.key, required this.student});

  @override
  _StudentProfileState createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  /// Carga las clases inscritas del estudiante desde Firestore
  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('students', arrayContains: widget.student.studentId)
          .get();

      final classes = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      setState(() {
        _classes = classes.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar clases: $e'),
        ),
      );
    }
  }

  /// Navegar a la pantalla de detalles de la clase
  void _navigateToClassDetails(Map<String, dynamic> classData) {
    // Aquí puedes implementar la navegación al perfil de la clase
    Navigator.pushNamed(
      context,
      '/classDetails', // Define esta ruta en `main.dart`
      arguments: classData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Estudiante'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                widget.student.firstName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 40),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${widget.student.firstName} ${widget.student.firstLastName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(widget.student.email),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la lógica para editar el perfil
                Navigator.pushNamed(
                  context,
                  '/studentForm', // Define esta ruta en `main.dart`
                  arguments: widget.student,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Editar Perfil'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Clases Inscritas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _classes.isEmpty
                      ? const Center(
                          child: Text('No hay clases inscritas.'),
                        )
                      : ListView.builder(
                          itemCount: _classes.length,
                          itemBuilder: (context, index) {
                            final classData = _classes[index];
                            return ListTile(
                              leading: const Icon(Icons.class_),
                              title: Text(classData['name']),
                              subtitle: Text(
                                'Estatus: ${classData['status']}',
                              ),
                              onTap: () {
                                _navigateToClassDetails(classData);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
