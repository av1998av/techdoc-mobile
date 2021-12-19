import 'package:flutter/material.dart';
import 'package:android/helpers/shared_pref_helper.dart';
import 'package:android/providers/api.dart';
import '../navbar.dart';

class PatientPage extends StatefulWidget {
  const PatientPage({Key? key}) : super(key: key);

  @override
  PatientPageState createState() => PatientPageState();
}

class PatientPageState extends State<PatientPage> {
  List patients = [];
  bool isLoading = false;
  
  @override
  void initState(){
    super.initState();
    fetchPatients();
  }
  
  fetchPatients() async {
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      final token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        patients = await Api.fetchPatients(token);
        setState(() {
          patients = patients;
          isLoading = false;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients')
      ),
      body: getBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () => {
          
        }
      ),
      drawer: const NavBar(),
    );
  }
  Widget getBody(){
    if(patients.contains(null) || patients.isEmpty || isLoading){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.builder(
      itemCount: patients.length,
      itemBuilder: (context,index){
      return getCard(patients[index]);
    });
  }
  Widget getCard(patient){
    var fullName = patient['name'];
    var email = patient['email'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          title: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(fullName.toString(), style: const TextStyle(fontSize: 17)),
                  const SizedBox(height: 10,),
                  Text(email.toString(), style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          )
        ),
      )
    );
  }
}