// ignore_for_file: prefer_const_constructors

import 'package:android/models/appointment.dart';
import 'package:android/models/patient.dart';
import 'package:android/themes/themes.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientExpanded extends StatelessWidget {
  final Patient patient;
  
  const PatientExpanded({Key? key, required this.patient}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      color: Colors.orange[100],
      child: Column(
        children: <Widget>[
          SizedBox(height: 15),
          Center(
            child: Text(
              patient.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 32,
                color: FitnessAppTheme.nearlyDarkBlue,
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              patient.id,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,                
                fontSize: 12,
                color: FitnessAppTheme.nearlyDarkBlue,
              ),
            ),
          ),
          SizedBox(height: 10),
          DataTable(
            columns: <DataColumn>[
              DataColumn(
                label: Text(patient.bloodGroup,
                  style: TextStyle(
                    fontSize: 25
                  ),
                ),
              ),
              DataColumn(
                label: patient.gender == 'male' ? Icon(Icons.male, color: Colors.blue, size: 25) : Icon(Icons.female, color: Colors.pink, size: 25)
              ),
              DataColumn(
                label: Text(patient.dob,
                  style: TextStyle(
                    fontSize: 25
                  ),
                ),
              ),
            ],
            rows: const <DataRow>[                            
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: FitnessAppTheme.background,
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 25, right: 25, top: 8, bottom: 15),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('Notes', 
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                    )
                  )
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 25, right: 25, bottom: 25),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(patient.notes ?? '',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15
                    )
                  )
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: FitnessAppTheme.background,
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 25, right: 25, top: 8, bottom: 15),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('Allergies', 
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                    )
                  )
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 25, right: 25, bottom: 25),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(patient.allergies ?? '',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15
                    )
                  )
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: FitnessAppTheme.background,
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 25, right: 25, top: 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('Previous Appointments', 
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                    )
                  )
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: patient.appointments.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context,index){
                return Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top:10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Card(
                      color: getColor(patient.appointments[index]),
                      child: ListTile(
                        title: Text(DateFormat('dd/MM/yyyy').format(patient.appointments[index].date))                      
                      )
                    )
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  getColor(appointment){
    if(appointment.status == 'Completed'){
      return Colors.blue[200];
    }
    else if(appointment.status == 'Cancelled'){
      return Colors.red[200];
    }
    else {
      return Colors.green[200];
    }
  }
}