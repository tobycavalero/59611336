// lib/teacher.dart
class Teacher {
  final String teacherId;
  final String firstName;
  final String lastName;
  final String email;
  final String? subject;
  final String? imagePath;

  Teacher({
    required this.teacherId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.subject,
    this.imagePath,
  });

  /// Crea una instancia de Teacher desde un mapa
  factory Teacher.fromMap(Map<String, dynamic> data, String id) {
    return Teacher(
      teacherId: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      subject: data['subject'],
      imagePath: data['imagePath'],
    );
  }

  /// Convierte la instancia de Teacher a un mapa
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'subject': subject,
      'imagePath': imagePath,
    };
  }
}
