import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassForm extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic>? classData;

  const ClassForm({super.key, required this.courseId, this.classData});

  @override
  State<ClassForm> createState() => ClassFormState(); // 🔹 Clase ahora pública
}

class ClassFormState extends State<ClassForm> {  // 🔹 Quitamos el "_" para hacerla pública
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.classData != null) {
      _nameController.text = widget.classData?['name'] ?? '';
      _daysController.text = widget.classData?['days'] ?? '';
      _timeController.text = widget.classData?['time'] ?? '';
    }
  }

  /// Guarda o actualiza la clase en Firestore
  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final classData = {
        'name': _nameController.text.trim(),
        'days': _daysController.text.trim(),
        'time': _timeController.text.trim(),
        'courseId': widget.courseId,
      };

      final classesCollection = FirebaseFirestore.instance.collection('classes');

      if (widget.classData == null) {
        // Nueva clase
        await classesCollection.add(classData);
      } else {
        // Actualizar clase existente
        await classesCollection.doc(widget.classData?['id']).update(classData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clase guardada con éxito')),
      );

      Navigator.pop(context); // Regresa a la lista de clases
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la clase: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classData == null ? 'Nueva Clase' : 'Editar Clase'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre de la Clase'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _daysController,
                decoration: const InputDecoration(labelText: 'Días (Ej: Lunes, Miércoles)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa los días.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Horario (Ej: 10:00 - 12:00)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el horario.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Clase'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
