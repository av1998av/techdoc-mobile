// ignore_for_file: prefer_const_constructors

import 'package:android/models/appointment.dart';
import 'package:android/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentExpanded extends StatelessWidget {
  final Appointment appointment;
  
  const AppointmentExpanded({ Key? key, required this.appointment}) :super(key: key);
  
  getIcon(){
    if(appointment.status == 'Completed'){
      return Icon(Icons.check, color: Colors.black, size: 30);
    }
    else if(appointment.status == 'Cancelled'){
      return Icon(Icons.close, color: Colors.black, size: 30);
    }
    else {
      return Icon(Icons.lock_clock, color: Colors.black, size: 30);
    }
  }
  
  getColor(){
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
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      color: getColor(),
      child: Column(
        children: <Widget>[
          SizedBox(height: 15),
          Center(
            child: Text(
              appointment.patientName,
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
              appointment.status,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,                
                fontSize: 12,
                color: FitnessAppTheme.nearlyDarkBlue,
              ),
            ),
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
                  child: Text(appointment.notes ?? '',
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
            padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 20),
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
                  child: Text('Prescription', 
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
            padding: const EdgeInsets.all(20),
            child: getPrescriptionDownloadButton()
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 20),
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
                  child: Text('Files', 
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                    )
                  )
                ),
              ),
            ],
          ),
          Column(
            children: getFileDownloadButtons(),
          )
        ],
      ),
    );
  }
  
  getPrescriptionDownloadButton(){
    if(appointment.prescriptionFileLink != null){
      return TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(FitnessAppTheme.background),                
        ),
        onPressed: (){
          openBrowser(appointment.prescriptionFileLink ?? '');
        }, 
        child: Text('Download Prescription',
          style: TextStyle(
            color: Colors.red[400]
          ),
        )
      );
    }
    else{
      return Text('Long press Appointment to add prescription');
    }
  }
  
  getFileDownloadButtons(){
    final children = <Widget>[];
    for (var i=0; i< appointment.files.length; i++){
      var fileName = appointment.files[i].toString().split('/').last.split('?').first;
      children.add(
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(FitnessAppTheme.background),                
          ),
          onPressed: (){
            openBrowser(appointment.files[i]);
          }, 
          child: Text(fileName,
            style: TextStyle(
              color: Colors.red[400]
            ),
          )
        )
      );
    }
    return children.isNotEmpty ? children : [Text('Long press Appointment to add files')];
  }
  
  Future<void> openBrowser(String url) async {
    if (!await launch(url,forceSafariVC: false,forceWebView: false)) {
      throw 'Could not launch $url';
    }
  }
}