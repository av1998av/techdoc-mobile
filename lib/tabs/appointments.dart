// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:android/components/appointment_view.dart';
import 'package:android/components/appointments_summary.dart';
import 'package:android/components/counter.dart';
import 'package:android/helpers/shared_pref_helper.dart';
import 'package:android/models/appointment.dart';
import 'package:android/models/custom_http_response.dart';
import 'package:android/models/drug.dart';
import 'package:android/models/patient.dart';
import 'package:android/providers/api.dart';
import 'package:android/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AppointmentsTab extends StatefulWidget {
  const AppointmentsTab({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  AppointmentsTabState createState() => AppointmentsTabState();
}

class AppointmentsTabState extends State<AppointmentsTab> with TickerProviderStateMixin {
  List<Appointment> allAppointments = [];
  List<Patient> patients = [];
  List<Drug> drugs = [];
  bool isLoading = false;
  String token = '';
  DateTime today = DateTime.now();
  final numberNotif = ValueNotifier<int>(0);
  final TextEditingController eventController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController patientController = TextEditingController();
  final List<TextEditingController> drugControllers = List.generate(10, (i) => TextEditingController());
  final List<TextEditingController> quantityControllers = List.generate(10, (i) => TextEditingController());
  final List<TextEditingController> scheduleControllers = List.generate(10, (i) => TextEditingController());
  Animation<double>? topBarAnimation;
  
  List<Patient> getPatientSuggestions(pattern) {
    return patients.where((patient) => patient.name.toLowerCase().contains(pattern)).toList();
  }
  
  List<Drug> getDrugSuggestions(pattern) {
    return drugs.where((drug) => drug.name.toLowerCase().contains(pattern)).toList();
  }
  
  addPrescription (String patientId, int appointmentId, List entries) async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customHttpResponse = await Api.addPrescription(patientId, appointmentId, entries, token);
        token = token;
        setState(() {
          isLoading = false;
        });
        Alert(
          context: context,
          style: FitnessAppTheme.alertStyle,
          buttons: [
            DialogButton(
              child: Text("Ok",style: TextStyle(color: Colors.white, fontSize: 20),),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
          title: customHttpResponse.message,
        ).show();
        if(customHttpResponse.status){          
          fetchAllAppointments();
        }
      }
    });
  }
  
  showAddPrescriptionDialog(int appointmentId, String patientId) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(10),
        title: Text("New Prescription"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width*0.75,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              child: Column(
                children: <Widget>[                  
                  NumericStepButton(
                    maxValue: 20,
                    minValue: 1,
                    current: max(1,numberNotif.value),
                    onChanged: (value) {
                      numberNotif.value = value;                      
                    },
                  ),
                  ValueListenableBuilder(valueListenable: numberNotif, builder: (context, int value, widget){
                    return Column(
                      children: <Widget>[
                        for (int i=0;i<max(value,1);i++) Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top:10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.lightBlue
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          child: getForm(i)
                        )
                      ]
                    );
                  }),
                ],
              )
            )
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Ok"),
            onPressed: () {
              Navigator.pop(context);
              List entries = [];
              int total = 0;
              var list = Iterable<int>.generate(max(numberNotif.value,1)).toList();
              for (var item in list) {
                entries.add({
                  "name" : '',
                  "schedule" : scheduleControllers[item].text,
                  "quantity" : quantityControllers[item].text,
                  "drugId" : drugControllers[item].text
                });
              }
              addPrescription(patientId,appointmentId,entries);
            }
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ],
      ),
    );
  }
  
  Widget getForm(int index){    
    return Column(
      children: <Widget>[
        TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
            decoration: InputDecoration(
              labelText: 'Drug',
              border: OutlineInputBorder()
            ),
            controller: drugControllers[index]
          ),
          suggestionsCallback: (pattern) async {
            return getDrugSuggestions(pattern);
          },
          itemBuilder: (context, Drug drug) {
            return ListTile(
              title: Text(drug.name),
              subtitle: Text(drug.unit)
            );
          }, 
          onSuggestionSelected: (Drug drug) {
            drugControllers[index].text = drug.id.toString();            
          },
        ),
        const SizedBox(height: 10,),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Schecule',
            border: OutlineInputBorder(),
          ),
          controller: scheduleControllers[index],
        ),
        const SizedBox(height: 10,),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder()
          ),
          controller: quantityControllers[index],
        )
      ]
    );
  }

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    
    fetchAllAppointments();
    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
  }
  
  
  
  Future<void> fetchAllAppointments() async {
    CustomHttpResponse customAppointmentsHttpResponse;
    CustomHttpResponse customPatientsHttpResponse;
    CustomHttpResponse customDrugsHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        token = token;
        final results = await Future.wait([
          Api.fetchDateAppointments(token,today),
          Api.fetchPatients(token),
          Api.fetchDrugs(token)
        ]);        
        customAppointmentsHttpResponse = results[0];  
        customPatientsHttpResponse = results[1]; 
        customDrugsHttpResponse = results[2];     
        token = token;
        if(customPatientsHttpResponse.status && customAppointmentsHttpResponse.status && customDrugsHttpResponse.status){
          allAppointments = customAppointmentsHttpResponse.items.cast();
          patients = customPatientsHttpResponse.items.cast();
          drugs = customDrugsHttpResponse.items.cast();
          addAllListData(allAppointments);
        }
        else{
          String message = '';
          if(customPatientsHttpResponse.status){
            message = customPatientsHttpResponse.message;
          }
          else if(customPatientsHttpResponse.status){
            message = customPatientsHttpResponse.message;
          }
          else{
            message = customDrugsHttpResponse.message;
          }
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(message),
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

  addAppointment(Appointment appointment) async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customHttpResponse = await Api.addAppointment(appointment, token);
        token = token;
        setState(() {
          isLoading = false;
        });
        Alert(
          context: context,
          style: FitnessAppTheme.alertStyle,
          buttons: [
            DialogButton(
              child: Text("Ok",style: TextStyle(color: Colors.white, fontSize: 20),),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
          title: customHttpResponse.message,
        ).show();
        if(customHttpResponse.status){
          fetchAllAppointments(); 
        }
      }
    });
  }
  
  cancelAppointment(int id) async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customHttpResponse = await Api.cancelAppointment(token, id);
        token = token;
        setState(() {
          isLoading = false;
        });
        Alert(
          context: context,
          style: FitnessAppTheme.alertStyle,
          buttons: [
            DialogButton(
              child: Text("Ok",style: TextStyle(color: Colors.white, fontSize: 20),),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
          title: customHttpResponse.message,
        ).show();
        if(customHttpResponse.status){
          fetchAllAppointments(); 
        }
      }
    });
  }

  completeAppointment(int id) async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customHttpResponse = await Api.completeAppointment(token, id);
        token = token;
        setState(() {
          isLoading = false;
        });
        Alert(
          context: context,
          style: FitnessAppTheme.alertStyle,
          buttons: [
            DialogButton(
              child: Text("Ok",style: TextStyle(color: Colors.white, fontSize: 20),),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
          title: customHttpResponse.message,
        ).show();
        if(customHttpResponse.status){
          fetchAllAppointments(); 
        }
      }
    });
  }
  
  updateAppointment(int id) async {    
    CustomHttpResponse customHttpResponse;
    await showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a note'),
          content: TextFormField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Note',                
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isLoading = true;
                });                
                Future.delayed(const Duration(seconds: 3), () async {
                  // Navigator.pop(context);
                  var token = await SharePreferenceHelper.getUserToken();
                  if(token != ''){                    
                    customHttpResponse = await Api.updateAppointment(token, id, notesController.text.toString());
                    token = token;                    
                    setState(() {
                      isLoading = false;
                    });                    
                    Alert(
                      context: context,
                      style: FitnessAppTheme.alertStyle,
                      buttons: [
                        DialogButton(
                          child: Text("Ok",style: TextStyle(color: Colors.white, fontSize: 20),),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                      title: customHttpResponse.message,
                    ).show();
                    if(customHttpResponse.status){
                      fetchAllAppointments(); 
                    }
                  }
                });
              }, 
              child: const Text('OK')
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                notesController.dispose;
                setState(() {
                  isLoading = false;
                });
              }, 
              child: const Text('Cancel')
            )
          ],
        );
      }
    );
  }
  
  addPrescriptionModal(int id) async {    
    CustomHttpResponse customHttpResponse;
    await showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a prescription'),
          content: TextFormField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Note',                
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Navigator.pop(context);
                setState(() {
                  isLoading = true;
                });                
                Future.delayed(const Duration(seconds: 3), () async {
                  Navigator.pop(context);
                  var token = await SharePreferenceHelper.getUserToken();
                  if(token != ''){                    
                    customHttpResponse = await Api.updateAppointment(token, id, notesController.text.toString());
                    token = token;                    
                    setState(() {
                      isLoading = false;
                    });                    
                    Alert(
                      context: context,
                      style: FitnessAppTheme.alertStyle,
                      buttons: [
                        DialogButton(
                          child: Text("Ok",style: TextStyle(color: Colors.white, fontSize: 20),),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                      title: customHttpResponse.message,
                    ).show();
                    if(customHttpResponse.status){
                      fetchAllAppointments(); 
                    }
                  }
                });
              }, 
              child: const Text('OK')
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                notesController.dispose;
                setState(() {
                  isLoading = false;
                });
              }, 
              child: const Text('Cancel')
            )
          ],
        );
      }
    );
  }

  List<Patient> getSuggestions(pattern) {
    return patients.where((patient) => patient.name.toLowerCase().contains(pattern)).toList();
  }
  
  showAddDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Add Appointment"),
        content: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
            decoration: InputDecoration(
              labelText: 'Patient',
              border: OutlineInputBorder()
            ),
            controller: eventController
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
            eventController.text = patient.id;
          },
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Ok"),
            onPressed: (){
              if(eventController.text.isEmpty){
                Navigator.pop(context);
                return;
              }
              else{
                var appointment = Appointment(0,'',eventController.text,'',today,'','');
                Navigator.pop(context);
                addAppointment(appointment);              
              }
            }
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: getBody()
      ),
    );
  }
  
  Widget getBody(){
    if(isLoading){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    else{
      return RefreshIndicator(
        child: Stack(
          children: <Widget>[
            getMainListViewUI(),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
        onRefresh: fetchAllAppointments
      );
    }
  }
  
  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }
  
  void handleClick(String value) {
    switch (value) {
      case 'Logout':
        break;
      case 'Settings':
        break;
    }
  }
  
  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: FitnessAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 30 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text(
                                  'Appointments',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: FitnessAppTheme.grey,
                                      size: 18,
                                    ),
                                  ),
                                  InkWell(
                                    child: Text(
                                      DateFormat('dd/MM/yyyy').format(today),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                        letterSpacing: -0.2,
                                        color: FitnessAppTheme.darkerText,
                                      ),                                      
                                    ),
                                    onTap: () async {
                                      today = (await showDatePicker(
                                        context: context,
                                        initialDate: today,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2025),                                        
                                      ))!;
                                      fetchAllAppointments();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                                onTap: () {
                                  showMenu<String>(
                                    context: context,
                                    position: RelativeRect.fromLTRB(25.0, 25.0, 0.0, 0.0),      //position where you want to show the menu on screen
                                    items: [                                      
                                      PopupMenuItem<String>(child: const Text('Settings')),
                                      PopupMenuItem<String>(child: const Text('Logout'), onTap: () async {
                                        await SharePreferenceHelper.logout();
                                        Navigator.pushReplacementNamed(context, '/login');
                                      })
                                    ],
                                    elevation: 8.0,
                                  );
                                },
                                child: Center(
                                  child: Icon(
                                    Icons.more_vert_outlined                                    
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
  
  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }
  
  void addAllListData(List<Appointment> appointments) {    
    listViews.clear();
    listViews.add(
      AppointmentsSummaryView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval((1 / 9) * 1, 1.0, curve: Curves.fastOutSlowIn)
          )
        ),
        animationController: widget.animationController!,
        total: appointments.length,
        completed: appointments.where((i) => i.status == 'Completed').toList().length,
        cancelled: appointments.where((i) => i.status == 'Cancelled').toList().length,
      ),
    );
    
    for(int i=0;i<appointments.length;i++){
      listViews.add(
        AppointmentView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: widget.animationController!,
              curve: Interval((1 / 9) * 5, 1.0, curve: Curves.fastOutSlowIn)
            )
          ),
          animationController: widget.animationController!,
          appointment: appointments[i],
          cancelAppointment: cancelAppointment,
          completeAppointment: completeAppointment,
          updateAppointment: updateAppointment,
          addPrescription: showAddPrescriptionDialog,
        ),
      );
    }
    
  }
  
}
