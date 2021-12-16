import 'package:flutter/material.dart';
import '../navbar.dart';

class PatientPage extends StatefulWidget {
  const PatientPage({Key? key}) : super(key: key);

  @override
  PatientPageState createState() => PatientPageState();
}

class PatientPageState extends State<PatientPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients')
      ),
      body: Column(
        children: const [
          Text("Patients")
        ],
      ),
      drawer: const NavBar(),
    );
  }
}