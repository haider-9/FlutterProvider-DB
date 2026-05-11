// Importing necessary packages for Flutter UI, custom models, provider for state management
import 'package:flutter/material.dart';
import 'package:lab5/student_model.dart';
import 'package:lab5/student_provider.dart';
import 'package:provider/provider.dart';

// Main function: Entry point of the app
// Sets up the Provider for StudentProvider to manage app state globally
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          StudentProvider(), // Creates an instance of StudentProvider
      child: MyApp(), // The root widget of the app
    ),
  );
}

// MyApp: Root stateless widget
// Defines the MaterialApp with title and home page
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student DB+Provider', // App title
      home: StudentHomePage(), // Home page widget
    );
  }
}

// StudentHomePage: Stateful widget for the main page
// Manages state for the student list, form inputs, etc.
class StudentHomePage extends StatefulWidget {
  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

// State class for StudentHomePage
class _StudentHomePageState extends State<StudentHomePage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  // Boolean for presence status
  bool _isPresent = true;

  // initState: Called when the widget is inserted into the tree
  // Loads students from the database asynchronously
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Uses context.read to access StudentProvider without listening for changes
      context.read<StudentProvider>().loadStudents();
    });
  }

  // dispose: Called when the widget is removed from the tree
  // Cleans up controllers to prevent memory leaks
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // _addStudent: Method to add a new student
  // Validates form, creates student object, adds to provider, clears form
  void _addStudent() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate form inputs
      final name = _nameController.text.trim(); // Get trimmed name
      final age = int.parse(_ageController.text.trim()); // Parse age
      final provider = context
          .read<StudentProvider>(); // Access provider for writing

      // Add student to the provider (which updates the database and notifies listeners)
      provider.addStudent(student(name: name, age: age, isPresent: _isPresent));

      // Clear form fields
      _nameController.clear();
      _ageController.clear();
      setState(() {
        _isPresent = true; // Reset presence to true
      });
      FocusScope.of(context).unfocus(); // Hide keyboard
    }
  }

  // build: Builds the UI
  // Returns a Scaffold with app bar and body containing form and student list
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student DB+Provider')), // App bar with title
      body: Padding(
        padding: const EdgeInsets.all(12.0), // Padding around body
        child: Column(
          children: [
            // Form for adding new students
            Form(
              key: _formKey, // Key for form validation
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Stretch children
                children: [
                  // Title text
                  Text(
                    'Add a new student',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12), // Spacer
                  // Name input field
                  TextFormField(
                    controller: _nameController, // Controller for name
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(), // Border style
                    ),
                    validator: (value) {
                      // Validation logic
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a student name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12), // Spacer
                  // Age input field
                  TextFormField(
                    controller: _ageController, // Controller for age
                    decoration: InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number, // Numeric keyboard
                    validator: (value) {
                      // Validation logic
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter an age';
                      }
                      final parsed = int.tryParse(value.trim()); // Try parse
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid age';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12), // Spacer
                  // Presence switch
                  SwitchListTile(
                    title: Text('Present'), // Label
                    value: _isPresent, // Current value
                    onChanged: (value) {
                      // Callback when changed
                      setState(() {
                        _isPresent = value; // Update state
                      });
                    },
                  ),
                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addStudent, // Add student on press
                          child: Text('Add Student'),
                        ),
                      ),
                      SizedBox(width: 12), // Spacer
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<StudentProvider>()
                              .loadStudents(), // Refresh students
                          child: Text('Refresh'),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 32), // Divider
                ],
              ),
            ),
            // Consumer widget to listen for changes in StudentProvider
            // Only rebuilds the subtree when provider notifies listeners
            Consumer<StudentProvider>(
              builder: (context, provider, child) {
                final students = provider.getStudents; // Get list of students
                final presentCount = students
                    .where((s) => s.isPresent)
                    .length; // Count present
                final absentCount =
                    students.length - presentCount; // Count absent
                return Column(
                  children: [
                    // Horizontal scrollable stats cards
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatCard(
                            'Total',
                            students.length,
                          ), // Total students
                          _buildStatCard(
                            'Present',
                            presentCount,
                          ), // Present count
                          _buildStatCard('Absent', absentCount), // Absent count
                        ],
                      ),
                    ),
                    SizedBox(height: 12), // Spacer
                    // Expandable list view of students
                    Expanded(
                      child: ListView.builder(
                        itemCount: students.length, // Number of items
                        itemBuilder: (context, index) {
                          final student = students[index]; // Current student
                          return ListTile(
                            title: Text(student.name), // Student name
                            subtitle: Text(
                              'Age: ${student.age}',
                            ), // Age subtitle
                            trailing: Switch(
                              value: student.isPresent, // Presence switch
                              onChanged: (value) {
                                provider.updateStudent(
                                  student.name,
                                  value,
                                ); // Update presence
                              },
                            ),
                            onLongPress: () {
                              provider.deleteStudent(
                                student.name,
                              ); // Delete on long press
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // _buildStatCard: Helper method to build stat cards
  // Takes title and value, returns a Card widget with title and value
  Widget _buildStatCard(String title, int value) {
    return Card(
      margin: const EdgeInsets.only(right: 12), // Margin between cards
      child: Padding(
        padding: const EdgeInsets.all(10), // Padding inside card
        child: Column(
          mainAxisSize: MainAxisSize.min, // Minimize height
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)), // Title
            SizedBox(height: 6), // Spacer
            Text(value.toString(), style: TextStyle(fontSize: 18)), // Value
          ],
        ),
      ),
    );
  }
}
