import 'package:android/models/patient.dart';
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
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final bloodGroupController = TextEditingController();
  final genderController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final allergiesController = TextEditingController();
  final notesController = TextEditingController();
  final preferredCommuncationController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  
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
  
  addPatient(Patient patient){
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        var result = await Api.addPatient(patient, token);
        setState(() {
          isLoading = false;
        });
        fetchPatients();
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Add Drug/Process'),
                content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',                
                        ),
                      ),
                      TextFormField(
                        controller: dobController,
                        decoration: const InputDecoration(
                          labelText: 'D.O.B'
                        ),
                      ),
                      TextFormField(
                        controller: bloodGroupController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Blood Group',
                        ),
                      ),
                      TextFormField(
                        controller: genderController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                        ),
                      ),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                        ),
                      ),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                      TextFormField(
                        controller: allergiesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Allergies',
                        ),
                      ),
                      TextFormField(
                        controller: notesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                        ),
                      ),
                      TextFormField(
                        controller: preferredCommuncationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Preferred Communication',
                        ),
                      ),
                      TextFormField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Height',
                        ),
                      ),
                      TextFormField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Weight',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () async { 
                    String name = nameController.text;
                    String dob = dobController.text;
                    String bloodGroup = bloodGroupController.text;
                    String gender = genderController.text;
                    String phone = phoneController.text;
                    String email = emailController.text;
                    String allergies = allergiesController.text;
                    String notes = notesController.text;
                    String preferredCommunication = preferredCommuncationController.text;
                    int height = int.parse(heightController.text);
                    int weight = int.parse(weightController.text);
                    Patient patient = Patient(name, dob, bloodGroup, gender, phone, email, allergies, notes, preferredCommunication, height, weight);
                    if (name != ''){
                      Navigator.pop(context);
                      await addPatient(patient);
                    }
                  },
                  child: const Text('Submit'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  }, 
                  child: const Text('Cancel')
                )
              ],
            );
          })
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