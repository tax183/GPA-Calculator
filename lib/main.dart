import 'package:flutter/material.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPA Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GPACalculatorScreen(),
    );
  }
}

class GPACalculatorScreen extends StatefulWidget {
  @override
  _GPACalculatorScreenState createState() => _GPACalculatorScreenState();
}

class _GPACalculatorScreenState extends State<GPACalculatorScreen> {
  final TextEditingController _previousGpaController = TextEditingController();
  final TextEditingController _previousCreditsController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _courses = [];
  double _finalGpa = 0.0;
  double _newGpa = 0.0;

  String _gpaDescription(double gpa) {
    if (gpa >= 4.5) return "ممتاز";
    if (gpa >= 3.75) return "جيد جدًا";
    if (gpa >= 2.75) return "جيد";
    if (gpa >= 2.0) return "مقبول";
    return "ضعيف";
  }

  void _calculateGPA() {
    double totalGradePoints = 0.0;
    double totalCredits = 0.0;

    for (var course in _courses) {
      totalGradePoints += course['grade'] * course['credit'];
      totalCredits += course['credit'];
    }

    setState(() {
      _newGpa = totalCredits == 0 ? 0.0 : totalGradePoints / totalCredits;

      double previousGpa = double.tryParse(_previousGpaController.text) ?? 0.0;
      double previousCredits =
          double.tryParse(_previousCreditsController.text) ?? 0.0;

      double overallGradePoints =
          (previousGpa * previousCredits) + totalGradePoints;
      double overallCredits = previousCredits + totalCredits;

      _finalGpa =
          overallCredits == 0 ? 0.0 : overallGradePoints / overallCredits;
    });
  }

  void _addCourse(String name, double grade, double credit) {
    setState(() {
      _courses.add({
        'name': name,
        'grade': grade,
        'credit': credit,
      });
      _calculateGPA();
    });
  }

  void _reset() {
    setState(() {
      _courses.clear();
      _previousGpaController.clear();
      _previousCreditsController.clear();
      _newGpa = 0.0;
      _finalGpa = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController gradeController = TextEditingController();
    final TextEditingController creditController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('حاسبة المعدل التراكمي'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _previousGpaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'المعدل السابق',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _previousCreditsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'عدد الساعات السابقة',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المقرر',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: gradeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'الدرجة (0 - 100)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'أدخل الدرجة';
                        }
                        final grade = double.tryParse(value);
                        if (grade == null || grade < 0 || grade > 100) {
                          return 'أدخل درجة صحيحة (0 - 100)';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: creditController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'عدد الساعات المعتمدة',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'أدخل عدد الساعات';
                        }
                        final credit = double.tryParse(value);
                        if (credit == null || credit <= 0) {
                          return 'أدخل عدد ساعات صحيح';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          double grade = double.parse(gradeController.text);
                          double weight;

                          if (grade >= 95) {
                            weight = 5.0;
                          } else if (grade >= 90) {
                            weight = 4.75;
                          } else if (grade >= 85) {
                            weight = 4.5;
                          } else if (grade >= 80) {
                            weight = 4.0;
                          } else if (grade >= 75) {
                            weight = 3.5;
                          } else if (grade >= 70) {
                            weight = 3.0;
                          } else if (grade >= 65) {
                            weight = 2.5;
                          } else if (grade >= 60) {
                            weight = 2.0;
                          } else {
                            weight = 1.0;
                          }

                          double credit = double.parse(creditController.text);
                          _addCourse(nameController.text, weight, credit);
                        }
                      },
                      child: Text('إضافة'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return ListTile(
                    title: Text('${course['name']}'),
                    subtitle: Text(
                        'الدرجة: ${course['grade']} - الساعات: ${course['credit']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _courses.removeAt(index);
                          _calculateGPA();
                        });
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              Text(
                'معدل المقررات الجديدة: ${_newGpa.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'المعدل التراكمي: ${_finalGpa.toStringAsFixed(2)} (${_gpaDescription(_finalGpa)})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _reset,
                child: Text('إعادة تعيين'),
                style: ElevatedButton.styleFrom(primary: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
