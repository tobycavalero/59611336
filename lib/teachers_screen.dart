import 'package:flutter/material.dart';
import 'package:inscribe/teacher.dart';
import 'teacher_form.dart';
import 'teacher_profile_screen.dart';
import 'theme.dart'; // Tema central para uniformidad

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  _TeachersScreenState createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredTeachers = [];
  List<Map<String, dynamic>> _allTeachers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterTeachers);
    _loadTeachers();
  }

  /// Carga los maestros desde Firestore o base de datos
  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Aquí reemplaza con Firebase Firestore si es necesario
      final teachers = [
        {
          'id': '1',
          'firstName': 'Carlos',
          'lastName': 'Pérez',
          'subject': 'Matemáticas',
          'email': 'carlos.perez@email.com',
        },
        {
          'id': '2',
          'firstName': 'María',
          'lastName': 'Gómez',
          'subject': 'Ciencias',
          'email': 'maria.gomez@email.com',
        },
      ];

      if (mounted) {
        setState(() {
          _allTeachers = teachers;
          _filteredTeachers = teachers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Error al cargar maestros: $e');
      }
    }
  }

  /// Muestra un mensaje de error
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  /// Filtra la lista de maestros
  void _filterTeachers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTeachers = _allTeachers.where((teacher) {
        final name = teacher['firstName']?.toString().toLowerCase() ?? '';
        final subject = teacher['subject']?.toString().toLowerCase() ?? '';
        return name.contains(query) || subject.contains(query);
      }).toList();
    });
  }

  /// Navega al perfil del maestro
  void _navigateToTeacherProfile(Map<String, dynamic> teacherData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherProfileScreen(
          teacher: Teacher.fromMap(teacherData, teacherData['id']),
        ),
      ),
    );
  }

  /// Navega al formulario de edición o creación de maestro
  void _navigateToTeacherForm(Map<String, dynamic>? teacherData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherForm(
          teacher: teacherData != null
              ? Teacher.fromMap(teacherData, teacherData['id'])
              : null,
        ),
      ),
    ).then((_) => _loadTeachers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Maestros',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor, // Uniformidad con el tema
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _navigateToTeacherForm(null),
          ),
        ],
      ),
      body: Column(
        children: [
          // Encabezado
          Container(
            width: double.infinity,
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: const Text(
              'Gestiona los maestros registrados en la plataforma',
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ),
          const SizedBox(height: 10.0),
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Maestro',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          // Lista de maestros o mensaje de carga
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTeachers.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay maestros registrados.',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredTeachers.length,
                        itemBuilder: (context, index) {
                          final teacher = _filteredTeachers[index];
                          return Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.accentColor,
                                child: Text(
                                  teacher['firstName']
                                      ?.substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${teacher['firstName']} ${teacher['lastName']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                teacher['subject'] ?? 'Sin asignatura',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              onTap: () => _navigateToTeacherProfile(teacher),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                                onPressed: () => _navigateToTeacherForm(teacher),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
