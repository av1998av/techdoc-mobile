import 'package:flutter/material.dart';
import '../navbar.dart';

class DrugPage extends StatefulWidget {
  const DrugPage({Key? key}) : super(key: key);

  @override
  DrugPageState createState() => DrugPageState();
}

class DrugPageState extends State<DrugPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drugs')
      ),
      body: Column(
        children: const [
          Text("Drugs")
        ],
      ),
      drawer: const NavBar(),
    );
  }
}