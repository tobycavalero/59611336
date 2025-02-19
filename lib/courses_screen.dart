import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_form.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = false;
  String _searchQuery = '';
  bool _isSortedAscending = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('courses').get();
      setState(() {
        _courses = snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _deleteCourse(String courseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este curso?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('courses').doc(courseId).delete();
              Navigator.pop(context);
              _loadCourses();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleSortOrder() {
    setState(() {
      _isSortedAscending = !_isSortedAscending;
      _courses.sort((a, b) => _isSortedAscending
          ? a['name'].compareTo(b['name'])
          : b['name'].compareTo(a['name']));
    });
  }

  void _showCourseDetails(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Descripción: ${course['description']}'),
            Text('Máximo de estudiantes: ${course['maxStudents']}'),
            Text('Asignado a: ${course['teacherId'] ?? 'No asignado'}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredCourses = _courses
        .where((course) => course['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Cursos'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(icon: const Icon(Icons.sort), onPressed: _toggleSortOrder),
          IconButton(icon: const Icon(Icons.home), onPressed: () => Navigator.pushNamed(context, '/home')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CourseForm()),
          ).then((_) => _loadCourses());
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar curso',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      return Card(
                        color: Colors.orange.shade100,
                        child: ListTile(
                          title: Text(course['name']),
                          subtitle: Text(course['description'] ?? 'Sin descripción'),
                          onTap: () => _showCourseDetails(course),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CourseForm(course: course)),
                                  ).then((_) => _loadCourses());
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCourse(course['id']),
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
    );
  }
}
