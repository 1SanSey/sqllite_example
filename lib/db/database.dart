import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqllite_example/model/student.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database? _database = null;
  String studentsTable = 'Students';
  String columnId = 'id';
  String columnName = 'name';

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _initDB();
      return _database;
    }
  }

  Future<Database?> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}Student.db';
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  void _createDB(Database? db, int version) async {
    await db!.execute(
        'CREATE TABLE $studentsTable ($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnName TEXT);');
  }

//READ
  Future<List<Student>> getStudents() async {
    Database? db = await database;
    final List<Student> studentsList = [];

    final List<Map<String, dynamic>> studentsMapList =
        await db!.query(studentsTable);

    for (var studentMap in studentsMapList) {
      studentsList.add(Student.fromMap(studentMap));
    }
    return studentsList;
  }

  //INSERT
  Future<Student> insertStudent(Student student) async {
    Database? db = await database;
    student.id = await db!.insert(studentsTable, student.toMap());
    return student;
  }

  //UPDATE
  Future<int> updateStudent(Student student) async {
    Database? db = await database;
    return await db!.update(studentsTable, student.toMap(),
        where: '$columnId = ?', whereArgs: [student.id]);
  }

  //DELETE
  Future<int> deleteStudent(int id) async {
    Database? db = await database;
    return await db!
        .delete(studentsTable, where: '$columnId = ?', whereArgs: [id]);
  }
}
