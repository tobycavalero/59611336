import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'student_form.dart';
import 'student.dart';
import 'student_profile_screen.dart';
import 'theme.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredStudents = [];
  List<Map<String, dynamic>> _allStudents = [];
  bool _isLoading = false;
  String _sortBy = "firstName"; // Default sorting criteria

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStudents);
    _loadStudents();
  }

  /// Carga estudiantes desde Firestore
  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance.collection('students').get();
      final students = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      if (mounted) {
        setState(() {
          _allStudents = students.cast<Map<String, dynamic>>();
          _filteredStudents = _allStudents;
          _sortStudents(); // Ordena la lista
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Error al cargar estudiantes: $e');
      }
    }
  }

  /// Filtra estudiantes por nombre
  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        final name = student['firstName']?.toString().toLowerCase() ?? '';
        final lastName = student['firstLastName']?.toString().toLowerCase() ?? '';
        return name.contains(query) || lastName.contains(query);
      }).toList();
      _sortStudents(); // Ordena después de filtrar
    });
  }

  /// Ordena los estudiantes según el criterio
  void _sortStudents() {
    _filteredStudents.sort((a, b) {
      return a[_sortBy]?.toString().compareTo(b[_sortBy]?.toString() ?? '') ?? 0;
    });
  }

  /// Cambia el criterio de ordenamiento
  void _changeSorting(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      _sortStudents();
    });
  }

  /// Elimina un estudiante desde Firestore
  Future<void> _deleteStudent(String id) async {
    try {
      await FirebaseFirestore.instance.collection('students').doc(id).delete();
      _loadStudents();
    } catch (error) {
      if (mounted) {
        _showErrorMessage('Error al eliminar estudiante: ${error.toString()}');
      }
    }
  }

  /// Muestra un mensaje de error
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Navega al formulario de edición del estudiante
  void _navigateToEditStudent(Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentForm(
          student: Student.fromMap(student),
        ),
      ),
    ).then((_) => _loadStudents());
  }

  /// Navega al perfil del estudiante
  void _navigateToStudentProfile(Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfile(
          student: Student.fromMap(student),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Estudiantes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeSorting,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "firstName",
                child: Text('Ordenar por Nombre'),
              ),
              const PopupMenuItem(
                value: "firstLastName",
                child: Text('Ordenar por Apellido'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudentForm()),
          ).then((_) => _loadStudents());
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Estudiante',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredStudents.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay estudiantes registrados.',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            return Card(
                              color: Colors.white,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.accentColor,
                                  child: Text(
                                    student['firstName']?.substring(0, 1).toUpperCase() ?? '',
                                    style: const TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  '${student['firstName']} ${student['firstLastName']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(student['email'] ?? 'Sin correo'),
                                onTap: () => _navigateToStudentProfile(student),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _navigateToEditStudent(student),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteStudent(student['id']),
                                    ),
                                  ],
                                ),
                              ),
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
