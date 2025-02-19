// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudentAdapter extends TypeAdapter<Student> {
  @override
  final int typeId = 0;

  @override
  Student read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Student(
      studentId: fields[0] as String,
      firstName: fields[1] as String,
      secondName: fields[2] as String?,
      firstLastName: fields[3] as String,
      secondLastName: fields[4] as String?,
      dateOfBirth: fields[5] as String,
      email: fields[6] as String,
      phone: fields[7] as String,
      streetAddress: fields[8] as String,
      city: fields[9] as String,
      state: fields[10] as String,
      zip: fields[11] as String,
      course: fields[12] as String?,
      courseDetails: fields[13] as String?,
      country: fields[14] as String,
      imagePath: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Student obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.studentId)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.secondName)
      ..writeByte(3)
      ..write(obj.firstLastName)
      ..writeByte(4)
      ..write(obj.secondLastName)
      ..writeByte(5)
      ..write(obj.dateOfBirth)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.phone)
      ..writeByte(8)
      ..write(obj.streetAddress)
      ..writeByte(9)
      ..write(obj.city)
      ..writeByte(10)
      ..write(obj.state)
      ..writeByte(11)
      ..write(obj.zip)
      ..writeByte(12)
      ..write(obj.course)
      ..writeByte(13)
      ..write(obj.courseDetails)
      ..writeByte(14)
      ..write(obj.country)
      ..writeByte(15)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
