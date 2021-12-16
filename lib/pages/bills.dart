import 'package:flutter/material.dart';
import '../navbar.dart';

class BillPage extends StatefulWidget {
  const BillPage({Key? key}) : super(key: key);

  @override
  BillPageState createState() => BillPageState();
}

class BillPageState extends State<BillPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills')
      ),
      body: Column(
        children: const [
          Text("Bills")
        ],
      ),
      drawer: const NavBar(),
    );
  }
}