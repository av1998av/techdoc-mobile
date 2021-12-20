// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:android/providers/api.dart';
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
  List<Appointment> allAppointments = [];
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
    // Implementation example
    // return appointments[day] ?? [];
    return allAppointments.where((appointment) => DateFormat('yyy-MM-dd').format(appointment.date) == DateFormat('yyy-MM-dd').format(day)).toList();
  }
  
  List<Appointment> getAppointmentsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ...getAppointmentsForDay(d),
    ];
  }

  fetchAllAppointments() async {
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        allAppointments = await Api.fetchAllAppointments(token);        
        token = token;
        setState(() {
          isLoading = false;
        });
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
  
  void onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      selectedDay = null;
      focusedDay = focusedDay;
      rangeStart = start;
      rangeEnd = end;
      rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      selectedAppointments.value = getAppointmentsForRange(start, end);
    } else if (start != null) {
      selectedAppointments.value = getAppointmentsForDay(start);
    } else if (end != null) {
      selectedAppointments.value = getAppointmentsForDay(end);
    }
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
        onPressed: _showAddDialog,
      ),
    );
  }
  _showAddDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Add Appointment"),
      content: TextFormField(controller: eventController,),
      actions: <Widget>[
        TextButton(
          child: Text("Ok"),
          onPressed: (){
            if(eventController.text.isEmpty){
              Navigator.pop(context);
              return;
            }
            else{
              if(appointments[selectedDay] != null){
                appointments[selectedDay]!.add(Appointment(eventController.text, 'Scheduled', selectedDay!));
                setState((){});
                Navigator.pop(context);
                eventController.clear();
                return; 
              }
              else{
                List<Appointment> newAppointments = [];
                newAppointments.add(Appointment(eventController.text, 'Scheduled', selectedDay!));
                DateTime dateTime = DateTime.utc(selectedDay!.year, selectedDay!.month, selectedDay!.day);
                appointments[dateTime] = newAppointments;
                selectedAppointments.value = getAppointmentsForDay(dateTime);
                Navigator.pop(context);
                eventController.clear();
                return;
              }
            }
          }
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
      ],
    ));
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
              // Use `CalendarStyle` to customize the UI
              outsideDaysVisible: false,
            ),
            onDaySelected: onDaySelected,
            onRangeSelected: onRangeSelected,
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
                      // onTap: () => print('${value[index]}'),
                      title: Text(value[index].patientName),
                      subtitle: Text(value[index].status),
                      onLongPress: () =>{
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Cancel/Complete Appointment'),
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                              ),
                              actions: [
                                TextButton(
                                  style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                  ),
                                  onPressed: () async { 
                                  
                                  },
                                  child: const Text('Complete'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
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