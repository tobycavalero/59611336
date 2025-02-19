import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal() {
    // Inicializa sqflite para plataformas de escritorio
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'students.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students(
        studentId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        lastName TEXT,
        dob TEXT,
        email TEXT,
        phone TEXT,
        address TEXT,
        contactNumber TEXT,
        course TEXT
      )
    ''');
  }

  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await database;
    return await db.insert('students', student);
  }

  Future<int> updateStudent(Map<String, dynamic> student) async {
    final db = await database;
    return await db.update(
      'students',
      student,
      where: 'studentId = ?',
      whereArgs: [student['studentId']],
    );
  }

  Future<int> deleteStudent(int studentId) async {
    final db = await database;
    return await db.delete(
      'students',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    final db = await database;
    return await db.query('students');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
