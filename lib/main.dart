import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'students_screen.dart';
import 'teacher_list.dart';
import 'teacher_profile_screen.dart';
import 'teacher_form.dart';
import 'management_screen.dart';
import 'student_profile_screen.dart';
import 'student_form.dart';
import 'student.dart';
import 'teacher.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Estudiantes',
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(userName: 'Allan Reyes'),
        '/students': (context) => const StudentsScreen(),
        '/studentProfile': (context) {
          final student = ModalRoute.of(context)!.settings.arguments as Student;
          return StudentProfile(student: student);
        },
        '/studentForm': (context) {
          final student = ModalRoute.of(context)?.settings.arguments as Student?;
          return StudentForm(student: student);
        },
        '/teachers': (context) => const TeacherList(),
        '/teacherProfile': (context) {
          final teacher = ModalRoute.of(context)!.settings.arguments as Teacher;
          return TeacherProfileScreen(teacher: teacher);
        },
        '/teacherForm': (context) {
          final teacher = ModalRoute.of(context)?.settings.arguments as Teacher?;
          return TeacherForm(teacher: teacher);
        },
        '/courses': (context) => const CoursesScreen(),
        '/management': (context) => const ManagementScreen(),
      },
    );
  }
}
