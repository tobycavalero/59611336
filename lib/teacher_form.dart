import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'teacher.dart';

class TeacherForm extends StatefulWidget {
  final Teacher? teacher;

  const TeacherForm({super.key, this.teacher});

  @override
  _TeacherFormState createState() => _TeacherFormState();
}

class _TeacherFormState extends State<TeacherForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _subjectController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.teacher?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.teacher?.lastName ?? '');
    _emailController = TextEditingController(text: widget.teacher?.email ?? '');
    _subjectController = TextEditingController(text: widget.teacher?.subject ?? '');
  }

  Future<void> _saveTeacher() async {
    if (_formKey.currentState!.validate()) {
      final teacher = Teacher(
        teacherId: widget.teacher?.teacherId ?? '',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        subject: _subjectController.text,
      );

      try {
        final collection = FirebaseFirestore.instance.collection('teachers');
        if (widget.teacher == null) {
          await collection.add(teacher.toMap());
        } else {
          await collection.doc(teacher.teacherId).update(teacher.toMap());
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario de Maestro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Materia'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTeacher,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
