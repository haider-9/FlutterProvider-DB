import 'package:flutter/foundation.dart';
import 'package:lab5/db_helper.dart';
import 'package:lab5/student_model.dart';

class StudentProvider with ChangeNotifier {
  List<student> _students = [];
  List<student> get getStudents => _students;
  Future<void> loadStudents() async {
    final datalist = await DBHelper.fetchStudents('students');
    _students = datalist
        .map(
          (e) => student(
            age: e['age'],
            name: e['name'],
            isPresent: e['isPresent'] == 1,
          ),
        )
        .toList();
    notifyListeners();
  }

  Future<void> addStudent(student s) async {
    await DBHelper.insertStudent('students', {
      'name': s.name,
      'age': s.age,
      'isPresent': s.isPresent ? 1 : 0,
    });
    await loadStudents();
  }

  Future<void> deleteStudent(String name) async {
    await DBHelper.deleteStudent('students', name);
    await loadStudents();
  }

  Future<void> updateStudent(String name, bool isPresent) async {
    await DBHelper.updateStudent('students', name, isPresent);
    await loadStudents();
  }
}
