// ignore_for_file: prefer_const_constructors
import 'package:android/models/custom_http_response.dart';
import 'package:android/models/patient.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:android/providers/api.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:android/helpers/shared_pref_helper.dart';
import '../models/appointment.dart';
import '../navbar.dart';
import 'package:intl/intl.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  AppointmentPageState createState() => AppointmentPageState();
}

class AppointmentPageState extends State<AppointmentPage> {
  String dropdownValue = 'One';
  List<Appointment> allAppointments = [];
  List<Patient> patients = [];
  late final ValueNotifier<List<Appointment>> selectedAppointments;
  CalendarFormat calendarFormat = CalendarFormat.month;
  RangeSelectionMode rangeSelectionMode = RangeSelectionMode.toggledOff; 
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  DateTime? rangeStart;
  DateTime? rangeEnd;
  bool isLoading = false;
  String token = '';
  final TextEditingController eventController = TextEditingController();
  bool isLoaded = false;
  
  @override
  void initState() {
    super.initState();
    fetchAllAppointments();
    selectedDay = focusedDay;
    selectedAppointments = ValueNotifier(getAppointmentsForDay(selectedDay!));
  }
  
  @override
  void dispose() {
    eventController.dispose();
    selectedAppointments.dispose();
    super.dispose();
  }
  
  List<Appointment> getAppointmentsForDay(DateTime day) {
    return allAppointments.where((appointment) => DateFormat('yyy-MM-dd').format(appointment.date) == DateFormat('yyy-MM-dd').format(day)).toList();
  }
  
  fetchAllAppointments() async {
    CustomHttpResponse customAppointmentsHttpResponse;
    CustomHttpResponse customPatientsHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        token = token;
        customAppointmentsHttpResponse = await Api.fetchAllAppointments(token);  
        customPatientsHttpResponse = await Api.fetchPatients(token);      
        token = token;
        if(customPatientsHttpResponse.status && customAppointmentsHttpResponse.status){
          allAppointments = customAppointmentsHttpResponse.items.cast();
          patients = customPatientsHttpResponse.items.cast();
        }
        else{
          String message = '';
          if(customPatientsHttpResponse.status){
            message = customPatientsHttpResponse.message;
          }
          else{
            message = customAppointmentsHttpResponse.message;
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
          fetchAllAppointments(); 
        }
      }
    });
  }

  void onDaySelected(DateTime incomingSelectedDay, DateTime focusedDay) {
    if (!isSameDay(selectedDay, incomingSelectedDay)) {
      setState(() {
        selectedDay = incomingSelectedDay;
        focusedDay = focusedDay;
        rangeStart = null; // Important to clean those
        rangeEnd = null;
        rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      selectedAppointments.value = getAppointmentsForDay(incomingSelectedDay);
    }
  }
  
  List<Patient> getSuggestions(pattern) {
    return patients.where((patient) => patient.name.toLowerCase().contains(pattern)).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments')
      ),
      body: getBody(),
      drawer: const NavBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(Icons.add),
        onPressed: showAddDialog,
      ),
    );
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
                var appointment = Appointment(0,'',eventController.text,'',selectedDay!);
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
  
  Widget getBody(){
    if(isLoading){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: [
        TableCalendar<Appointment>(
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          rangeStartDay: rangeStart,
          rangeEndDay: rangeEnd,
          calendarFormat: calendarFormat,
          rangeSelectionMode: rangeSelectionMode,
          eventLoader: getAppointmentsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
          ),
          onDaySelected: onDaySelected,
          onFormatChanged: (format) {
            if (calendarFormat != format) {
              setState(() {
                calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Appointment>>(
            valueListenable: selectedAppointments,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      title: Text(value[index].patientName),
                      subtitle: Text(value[index].status),
                      onLongPress: () =>{
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Cancel/Complete Appointment'),
                              actions: [
                                TextButton(
                                  onPressed: () { 
                                    Navigator.pop(context);
                                    completeAppointment(value[index].id);
                                  },
                                  child: const Text('Complete'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    cancelAppointment(value[index].id);
                                  }, 
                                  child: const Text('Cancel')
                                )
                              ],
                            );
                          }
                        )
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),        
      ],
    );
  }
}