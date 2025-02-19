import 'package:hive/hive.dart';
import 'package:flutter/material.dart'; // Import necesario para TextEditingController

part 'student.g.dart';

@HiveType(typeId: 0)
class Student extends HiveObject {
  @HiveField(0)
  String studentId;

  @HiveField(1)
  String firstName;

  @HiveField(2)
  String? secondName;

  @HiveField(3)
  String firstLastName;

  @HiveField(4)
  String? secondLastName;

  @HiveField(5)
  String dateOfBirth;

  @HiveField(6)
  String email;

  @HiveField(7)
  String phone;

  @HiveField(8)
  String streetAddress;

  @HiveField(9)
  String city;

  @HiveField(10)
  String state;

  @HiveField(11)
  String zip;

  @HiveField(12)
  String? course;

  @HiveField(13)
  String? courseDetails;

  @HiveField(14)
  String country;

  @HiveField(15)
  String? imagePath;

  @HiveField(16)
  List<EmergencyContact>? emergencyContacts;

  Student({
    required this.studentId,
    required this.firstName,
    this.secondName,
    required this.firstLastName,
    this.secondLastName,
    required this.dateOfBirth,
    required this.email,
    required this.phone,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.zip,
    this.course,
    this.courseDetails,
    required this.country,
    String? imagePath,
    this.emergencyContacts,
  }) {
    this.imagePath = (imagePath?.isNotEmpty ?? false) ? imagePath : null;
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      studentId: map['studentId']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      secondName: map['secondName']?.toString(),
      firstLastName: map['firstLastName']?.toString() ?? '',
      secondLastName: map['secondLastName']?.toString(),
      dateOfBirth: map['dateOfBirth']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      streetAddress: map['streetAddress']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      zip: map['zip']?.toString() ?? '',
      course: map['course']?.toString(),
      courseDetails: map['courseDetails']?.toString(),
      country: map['country']?.toString() ?? 'Estados Unidos',
      imagePath: map['imagePath']?.toString(),
      emergencyContacts: (map['emergencyContacts'] as List<dynamic>?)
          ?.map((e) => EmergencyContact.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'firstName': firstName,
      'secondName': secondName,
      'firstLastName': firstLastName,
      'secondLastName': secondLastName,
      'dateOfBirth': dateOfBirth,
      'email': email,
      'phone': phone,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'zip': zip,
      'course': course,
      'courseDetails': courseDetails,
      'country': country,
      'imagePath': imagePath?.isNotEmpty == true ? imagePath : null,
      'emergencyContacts': emergencyContacts?.map((e) => e.toMap()).toList(),
    };
  }
}

@HiveType(typeId: 1)
class EmergencyContact {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String relation;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relation: map['relation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'relation': relation,
    };
  }
}

class EmergencyContactFormField {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController relationController;

  EmergencyContactFormField()
      : nameController = TextEditingController(),
        phoneController = TextEditingController(),
        relationController = TextEditingController();
}
