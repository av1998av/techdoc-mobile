// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:android/models/bill.dart';
import 'package:android/models/patient.dart';
import 'package:flutter/material.dart';
import 'package:android/helpers/shared_pref_helper.dart';
import 'package:url_launcher/link.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android/providers/api.dart';
import '../navbar.dart';

class BillPage extends StatefulWidget {
  const BillPage({Key? key}) : super(key: key);

  @override
  BillPageState createState() => BillPageState();
}

class BillPageState extends State<BillPage> {
  List<Bill> bills = [];
  List<Patient> patients = [];
  bool isLoading = false;
  final TextEditingController patientController = TextEditingController();
  final TextEditingController numberOfItemsController = TextEditingController();
  
  List<Patient> getSuggestions(pattern) {
    return patients.where((patient) => patient.name.toLowerCase().contains(pattern)).toList();
  }
  
  @override
  void initState(){
    super.initState();
    numberOfItemsController.text = '1';
    fetchBills();
  }
  
  fetchBills() async {
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      final token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        bills = await Api.fetchBills(token);
        patients = await Api.fetchPatients(token);      
        setState(() {
          bills = bills;
          isLoading = false;
        });
      }
    });
  }
  
  Future<void> openBrowser(String url) async {
    if (!await launch(url,forceSafariVC: false,forceWebView: false)) {
      throw 'Could not launch $url';
    }
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
        child: Icon(Icons.add),
        onPressed: showAddDialog,
      ),
      drawer: const NavBar(),
    );
  }
  
  showAddDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(10),
        title: Text("New Bill"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width*0.75,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              child: Column(
                children: <Widget>[
                  TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Patient',
                        border: OutlineInputBorder()
                      ),
                      controller: patientController
                    ),
                    suggestionsCallback: (pattern) async {
                      return getSuggestions(pattern);
                    },
                    itemBuilder: (context, Patient patient) {
                      return ListTile(
                        title: Text(patient.name),
                        subtitle: Text(patient.id)
                      );
                    }, 
                    onSuggestionSelected: (Patient patient) {
                      patientController.text = patient.id;
                    },
                  ),
                  const SizedBox(height: 10,),
                  TextFormField(
                    controller: numberOfItemsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number of Products',
                      border: OutlineInputBorder()
                    ),
                  ),
                  for (int i=0;i<max(int.parse(numberOfItemsController.text),1);i++) Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(top:10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.lightBlue
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                    ),
                    child: getForm()
                  ),
                ],
              )
            )
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Ok"),
            onPressed: (){
              
            }
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ],
      ),
    );
  }
  
  Widget getForm(){
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Drug/Process',
            border: OutlineInputBorder()
          ),
        ),
        const SizedBox(height: 10,),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Price',
            border: OutlineInputBorder()
          ),
        ),
        const SizedBox(height: 10,),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder()
          ),
        ),
        const SizedBox(height: 10,),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Cost',
            border: OutlineInputBorder()
          ),
        ),                
      ]
    );
  }
  
  Widget getBody(){
    if(bills.contains(null) || bills.isEmpty || isLoading){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (context,index){
      return getCard(bills[index]);
    });
  }
  Widget getCard(Bill bill){
    var fullName = bill.name;
    var total = bill.total;
    var link = bill.fileLink;
    var method = bill.paymentMethod;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(fullName.toString(), style: const TextStyle(fontSize: 17)),
                  const SizedBox(height: 10,),
                  Text(total.toString(), style: const TextStyle(color: Colors.grey)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      openBrowser(link);
                    },
                    child: const Icon(Icons.download_rounded, color: Colors.white),
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
          )
        ),
      )
    );
  }
}