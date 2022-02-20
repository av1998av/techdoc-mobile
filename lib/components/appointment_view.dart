// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new

import 'package:android/models/appointment.dart';
import 'package:android/themes/themes.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/material.dart';

import 'appointment_expanded.dart';

class AppointmentView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  Appointment appointment;
  final Function(int) cancelAppointment;
  final Function(int) completeAppointment;
  final Function(int) updateAppointment;
  final Function(int) addFiles;
  final Function(int, String) addPrescription;
  
  AppointmentView({Key? key, this.animationController, this.animation, required this.appointment, required this.cancelAppointment, required this.completeAppointment, required this.updateAppointment, required this.addPrescription, required this.addFiles})
      : super(key: key);
      
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
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: new Transform(
            transform: new Matrix4.translationValues(0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: getColor(),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(8.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: FitnessAppTheme.grey.withOpacity(0.2),
                        offset: Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: InkWell(
                  child: Column(
                    children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16, right: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, bottom: 3),
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
                                  )                                  
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () async {
                                      
                                    },
                                    // child: getIcon(),
                                    child: Text(DateFormat('hh:mm a').format(appointment.date), style: TextStyle(
                                      fontSize: 20
                                    ))
                                  ), 
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 8),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: FitnessAppTheme.background,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                InkWell(
                                      onTap: () async {
                                        cancelAppointment(appointment.id);
                                      },
                                      child: Text(
                                        'Cancel',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          letterSpacing: -0.2,
                                          color: Colors.red,
                                        ),
                                      ), 
                                    )                                
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () async {
                                        completeAppointment(appointment.id);
                                      },
                                      child: Text(
                                        'Complete',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          letterSpacing: -0.2,
                                          color: Colors.green,
                                        ),
                                      ), 
                                    )                                   
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    InkWell(
                                      child: Text(
                                        'View',
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          letterSpacing: -0.2,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      onTap: () => {
                                        showMaterialModalBottomSheet(
                                          context: context,
                                          builder: (context) => AppointmentExpanded(appointment: appointment),
                                        )
                                      }, 
                                    )                                                                       
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                    ],
                  ),
                  onLongPress: () => {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text("Update Appointment"),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Add Prescription"),
                            onPressed: (){
                              Navigator.pop(context);
                              addPrescription(appointment.id, appointment.patientId);
                            }
                          ),
                          TextButton(
                            child: Text("Add note"),
                            onPressed: (){
                              Navigator.pop(context);
                              updateAppointment(appointment.id);
                            }
                          ),
                          TextButton(
                            child: Text("Add files"),
                            onPressed: (){
                              Navigator.pop(context);
                              addFiles(appointment.id);
                            }
                          ),
                          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                        ],
                      )
                    )
                  },
                )
              ),
            ),
          ),
        );
      },
    );
  }
}
