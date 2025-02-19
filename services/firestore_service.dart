import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Agregar un estudiante
  Future<void> addStudent(Map<String, dynamic> studentData) async {
    try {
      await _db.collection('students').add(studentData);
    } catch (e) {
      print('Error al agregar estudiante: $e');
    }
  }

  // Obtener todos los estudiantes
  Stream<List<Map<String, dynamic>>> getStudents() {
    return _db.collection('students').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Actualizar un estudiante
  Future<void> updateStudent(String studentId, Map<String, dynamic> updatedData) async {
    try {
      await _db.collection('students').doc(studentId).update(updatedData);
    } catch (e) {
      print('Error al actualizar estudiante: $e');
    }
  }

  // Eliminar un estudiante
  Future<void> deleteStudent(String studentId) async {
    try {
      await _db.collection('students').doc(studentId).delete();
    } catch (e) {
      print('Error al eliminar estudiante: $e');
    }
  }
}
