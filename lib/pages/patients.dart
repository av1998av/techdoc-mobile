// ignore_for_file: unnecessary_null_comparison, prefer_const_constructors

import 'package:android/models/custom_http_response.dart';
import 'package:android/models/patient.dart';
import 'package:flutter/material.dart';
import 'package:android/helpers/shared_pref_helper.dart';
import 'package:android/providers/api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../navbar.dart';

class PatientPage extends StatefulWidget {
  const PatientPage({Key? key}) : super(key: key);

  @override
  PatientPageState createState() => PatientPageState();
}

class PatientPageState extends State<PatientPage> {
  List<Patient> patients = [];
  String token = '';
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
  
  Future<void> fetchPatients() async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customHttpResponse = await Api.fetchPatients(token);
        token = token;
        if(customHttpResponse.status){
          patients = customHttpResponse.items.cast();
        }
        else{
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(customHttpResponse.message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    }, 
                    child: const Text('OK')
                  )
                ],
              );
            }
          );
        }
        setState(() {
          isLoading = false;
        });
      }
    });
  }
  
  addPatient(Patient patient){
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        var customHttpResponse = await Api.addPatient(patient, token);
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(customHttpResponse.message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  }, 
                  child: const Text('OK')
                )
              ],
            );
          }
        );
        if(customHttpResponse.status){
          fetchPatients();
        }
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
                    Patient patient = Patient('fakeId',name, dob, bloodGroup, gender, phone, email, allergies, notes, preferredCommunication, height, weight);
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
    return RefreshIndicator(
      child: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context,index){
          return getCard(patients[index]);
        }
      ), 
      onRefresh: fetchPatients
    );
  }
  Widget getCard(Patient patient){
    var fullName = patient.name;
    var contact = (patient.email == null) ? patient.phone : patient.email;
    return InkWell(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(patient.name, style: const TextStyle(fontSize: 17)),
                    const SizedBox(height: 10,),
                    Text(patient.id, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        if(patient.email == null){
                          var url = 'tel:+91'+patient.phone.toString();
                          if (await canLaunch(url)) {
                            await launch(url);
                          } 
                          else {
                            throw 'Could not launch $url';
                          } 
                        }
                        else if(patient.phone == null){
                          var url = 'mailto:'+patient.email.toString();
                          if (await canLaunch(url)) {
                            await launch(url);
                          } 
                          else {
                            throw 'Could not launch $url';
                          } 
                        }
                      },
                      child: patient.email == null ? Icon(Icons.phone, color: Colors.white) : Icon(Icons.mail, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        primary: Colors.blue, // <-- Button color
                        onPrimary: Colors.red, // <-- Splash color
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      onTap: () async  {
        Alert(
          context: context,
          style: alertStyle,
          title: fullName,
          buttons: [
            DialogButton(
              child: Text(
                "Close",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              color: Color.fromRGBO(0, 179, 134, 1.0),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Id: ", style: TextStyle(color: Colors.grey, fontSize: 17)),
                  Text(patient.id, style: TextStyle(fontSize: 17)),    
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Contact: ", style: TextStyle(color: Colors.grey, fontSize: 17)),
                  Text(contact.toString(), style: TextStyle(fontSize: 17)),    
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Date of Birth: ", style: TextStyle(color: Colors.grey, fontSize: 17)),
                  Text(patient.dob, style: TextStyle(fontSize: 17)),    
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Blood Group: ", style: TextStyle(color: Colors.grey, fontSize: 17)),
                  Text(patient.bloodGroup, style: TextStyle(fontSize: 17)),    
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Gender: ", style: TextStyle(color: Colors.grey, fontSize: 17)),
                  Text(patient.gender, style: TextStyle(fontSize: 17)),    
                ],
              ),
              const SizedBox(height: 10,),
              Text("Allergies: ", style: TextStyle(color: Colors.grey, fontSize: 17)),
              Text(patient.allergies, style: TextStyle(fontSize: 17)),
              const SizedBox(height: 10,),
              Text("Notes: ", style: TextStyle(color: Colors.grey, fontSize: 17)),
              Text(patient.notes, style: TextStyle(fontSize: 17)),
            ],
          ),
        ).show();
      }, 
    );
  }
  var alertStyle = AlertStyle(
    animationType: AnimationType.fromTop,
    isCloseButton: false,
    isOverlayTapDismiss: true,
    descStyle: const TextStyle(fontWeight: FontWeight.bold),
    animationDuration: Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
      side: BorderSide(
        color: Colors.grey,
      ),
    ),
    titleStyle: const TextStyle(
      color: Color.fromRGBO(91, 55, 185, 1.0),
    ),
  );
}