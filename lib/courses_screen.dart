import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = false;
  String _searchQuery = '';

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

  Future<void> _deleteCourse(String courseId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar eliminación"),
        content: Text("¿Seguro que deseas eliminar este curso?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Eliminar", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (!confirm) return;

    try {
      await FirebaseFirestore.instance.collection('courses').doc(courseId).delete();
      _loadCourses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error eliminando: $e')));
    }
  }

  void _showCourseDetails(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Descripción: ${course['description']}"),
            Text("Maestro: ${course['teacherId']}"),
            Text("Máx. Estudiantes: ${course['maxStudents']}"),
            Text("Estudiantes inscritos: ${course['students'].length}"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Cerrar"))],
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CourseSearchDelegate(_courses, _showCourseDetails),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              setState(() {
                _courses.sort((a, b) => a['name'].compareTo(b['name']));
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushNamed(context, '/home'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredCourses.isEmpty
              ? const Center(child: Text("No hay cursos disponibles"))
              : ListView.builder(
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    return ListTile(
                      title: Text(course['name']),
                      subtitle: Text(course['description'] ?? 'Sin descripción'),
                      onTap: () => _showCourseDetails(course),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.pushNamed(context, '/courseForm', arguments: course).then((_) => _loadCourses());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCourse(course['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/courseForm').then((_) => _loadCourses());
        },
      ),
    );
  }
}

class CourseSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> courses;
  final Function(Map<String, dynamic>) onSelect;

  CourseSearchDelegate(this.courses, this.onSelect);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildCourseList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildCourseList();
  }

  Widget _buildCourseList() {
    List<Map<String, dynamic>> filtered = courses.where((course) => course['name'].toLowerCase().contains(query.toLowerCase())).toList();

    if (filtered.isEmpty) return Center(child: Text("No hay resultados"));

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final course = filtered[index];
        return ListTile(
          title: Text(course['name']),
          subtitle: Text(course['description'] ?? 'Sin descripción'),
          onTap: () => onSelect(course),
        );
      },
    );
  }
}
