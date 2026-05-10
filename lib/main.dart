import 'package:flutter/material.dart';
import 'package:lab5/student_model.dart';
import 'package:lab5/student_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => StudentProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Student DB+Provider', home: StudentHomePage());
  }
}

class StudentHomePage extends StatefulWidget {
  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  bool _isPresent = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<StudentProvider>(context, listen: false).loadStudents();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _addStudent() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final age = int.parse(_ageController.text.trim());
      final provider = Provider.of<StudentProvider>(context, listen: false);

      provider.addStudent(student(name: name, age: age, isPresent: _isPresent));

      _nameController.clear();
      _ageController.clear();
      setState(() {
        _isPresent = true;
      });
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final students = provider.getStudents;
    final presentCount = students.where((s) => s.isPresent).length;
    final absentCount = students.length - presentCount;

    return Scaffold(
      appBar: AppBar(title: Text('Student DB+Provider')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add a new student',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a student name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter an age';
                      }
                      final parsed = int.tryParse(value.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid age';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  SwitchListTile(
                    title: Text('Present'),
                    value: _isPresent,
                    onChanged: (value) {
                      setState(() {
                        _isPresent = value;
                      });
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addStudent,
                          child: Text('Add Student'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: provider.loadStudents,
                          child: Text('Refresh'),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 32),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard('Total', students.length),
                  _buildStatCard('Present', presentCount),
                  _buildStatCard('Absent', absentCount),
                ],
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return ListTile(
                    title: Text(student.name),
                    subtitle: Text('Age: ${student.age}'),
                    trailing: Switch(
                      value: student.isPresent,
                      onChanged: (value) {
                        provider.updateStudent(student.name, value);
                      },
                    ),
                    onLongPress: () {
                      provider.deleteStudent(student.name);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(value.toString(), style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
