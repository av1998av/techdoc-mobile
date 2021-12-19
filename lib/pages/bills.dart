import 'package:flutter/material.dart';
import 'package:android/helpers/shared_pref_helper.dart';
import 'package:android/providers/api.dart';
import '../navbar.dart';

class BillPage extends StatefulWidget {
  const BillPage({Key? key}) : super(key: key);

  @override
  BillPageState createState() => BillPageState();
}

class BillPageState extends State<BillPage> {
  List bills = [];
  bool isLoading = false;
  
  @override
  void initState(){
    super.initState();
    // fetchBills();
  }
  
  fetchBills() async {
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      final token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        bills = await Api.fetchBills(token);
        setState(() {
          bills = bills;
          isLoading = false;
        });
      }
    });
  }
  
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