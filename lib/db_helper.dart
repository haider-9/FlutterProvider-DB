import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> openDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'student.db'),
      onCreate: (db, version) => db.execute(
        'CREATE TABLE students(name TEXT,age INTEGER,isPresent INTEGER)',
      ),
      version: 1,
    );
  }

  static Future<void> insertStudent(
    String table,
    Map<String, dynamic> data,
  ) async {
    final db = await openDB();
    await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> fetchStudents(String table) async {
    final db = await openDB();
    return db.query(table);
  }

  static Future<void> deleteStudent(String table, String name) async {
    final db = await openDB();
    await db.delete(table, where: 'name = ?', whereArgs: [name]);
  }

  static Future<void> updateStudent(
    String table,
    String name,
    bool isPresent,
  ) async {
    final db = await openDB();
    await db.update(
      table,
      {'isPresent': isPresent ? 1 : 0},
      where: 'name = ?',
      whereArgs: [name],
    );
  }
}
