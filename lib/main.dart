import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqllite_example/db/database.dart';
import 'package:sqllite_example/model/student.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SQLite CRUD Demo',
      home: StudentPage(),
    );
  }
}

class StudentPage extends StatefulWidget {
  const StudentPage({Key? key}) : super(key: key);
  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();

  late Future<List<Student>> _studentsList;
  late String _studentName;
  bool isUpdate = false;
  late int? studentIdForUpdate;

  @override
  void initState() {
    super.initState();
    updateStudentList();
  }

  void updateStudentList() {
    setState(() {
      _studentsList = DBProvider.db.getStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite CRUD Demo'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: <Widget>[
          Form(
            key: _formStateKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null) {
                        return 'Please Enter Student Name';
                      }
                      if (value.trim() == "") {
                        return 'Only Space is Not Valid!!!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _studentName = value!;
                    },
                    controller: _studentNameController,
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.greenAccent,
                            width: 2,
                            style: BorderStyle.solid),
                      ),
                      labelText: "Student Name",
                      icon: Icon(
                        Icons.people,
                        color: Colors.black,
                      ),
                      fillColor: Colors.white,
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  textStyle: const TextStyle(color: Colors.white),
                ),
                // color: Colors.green,
                child: Text(isUpdate ? 'UPDATE' : 'ADD'),
                onPressed: () {
                  if (isUpdate) {
                    if (_formStateKey.currentState!.validate()) {
                      _formStateKey.currentState!.save();

                      DBProvider.db
                          .updateStudent(
                              Student(studentIdForUpdate, _studentName))
                          .then((data) {
                        setState(() {
                          isUpdate = false;
                        });
                      });
                    }
                  } else {
                    if (_formStateKey.currentState!.validate()) {
                      _formStateKey.currentState!.save();
                      DBProvider.db.insertStudent(Student(null, _studentName));
                    }
                  }
                  _studentNameController.text = '';
                  updateStudentList();
                },
              ),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  textStyle: const TextStyle(color: Colors.white),
                ),
                child: Text(isUpdate ? 'CANCEL UPDATE' : 'CLEAR'),
                onPressed: () {
                  _studentNameController.text = '';
                  setState(() {
                    isUpdate = false;
                    studentIdForUpdate = null;
                  });
                },
              ),
            ],
          ),
          const Divider(
            height: 5.0,
          ),
          Expanded(
            child: FutureBuilder(
              future: _studentsList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Student> s = snapshot.data as List<Student>;
                  return generateList(s);
                }
                if (snapshot.data == null) {
                  const Text('Data of students not found!');
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView generateList(List<Student> students) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('NAME')),
              DataColumn(label: Text('DELETE'))
            ],
            rows: students
                .map(
                  (student) => DataRow(cells: [
                    DataCell(Text(student.name ?? ''), onTap: () {
                      setState(() {
                        isUpdate = true;
                        studentIdForUpdate = student.id;
                      });
                      _studentNameController.text = student.name ?? '';
                    }),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          DBProvider.db.deleteStudent(student.id ?? 0);
                          updateStudentList();
                        },
                      ),
                    ),
                  ]),
                )
                .toList(),
          )),
    );
  }
}
