import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'class_form.dart';

class ClassListScreen extends StatefulWidget {
  final String courseId; // ID del curso asociado

  const ClassListScreen({super.key, required this.courseId});

  @override
  _ClassListScreenState createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  /// Carga las clases desde Firestore
  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('courseId', isEqualTo: widget.courseId)
          .get();

      final classes = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      setState(() {
        _classes = classes.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar clases: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Navega a la pantalla de formulario de clase
  void _navigateToClassForm({Map<String, dynamic>? classData}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassForm(
          courseId: widget.courseId,
          classData: classData,
        ),
      ),
    ).then((_) => _loadClasses());
  }

  /// Elimina una clase en Firestore
  Future<void> _deleteClass(String id) async {
    try {
      await FirebaseFirestore.instance.collection('classes').doc(id).delete();
      _loadClasses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la clase: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clases del Curso'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToClassForm(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _classes.isEmpty
                ? const Center(child: Text('No hay clases registradas.'))
                : ListView.builder(
                    itemCount: _classes.length,
                    itemBuilder: (context, index) {
                      final classData = _classes[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4.0,
                        child: ListTile(
                          title: Text(
                            classData['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(classData['description'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _navigateToClassForm(classData: classData),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Eliminar Clase'),
                                      content: const Text(
                                          '¿Estás seguro de que deseas eliminar esta clase?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _deleteClass(classData['id']);
                                          },
                                          child: const Text(
                                            'Eliminar',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
