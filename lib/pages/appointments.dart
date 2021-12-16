// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import '../navbar.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  AppointmentPageState createState() => AppointmentPageState();
}

class AppointmentPageState extends State<AppointmentPage> {
  late SharedPreferences logindata;
  late final ValueNotifier<List<Appointment>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff; 
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final TextEditingController _eventController = TextEditingController();
  late bool newuser;
  bool isLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }
  
  @override
  void dispose() {
    _eventController.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }
  
  

  List<Appointment> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }
  
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments')
      ),
      body: Column(
        children: [
          TableCalendar<Appointment>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              // Use `CalendarStyle` to customize the UI
              outsideDaysVisible: false,
            ),
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Appointment>>(
              valueListenable: _selectedEvents,
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
                        onTap: () => print('${value[index]}'),
                        title: Text(value[index].patientName),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
        ],
      ),
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
      title: Text("Add Events"),
      content: TextFormField(controller: _eventController,),
      actions: <Widget>[
        TextButton(
          child: Text("Ok"),
          onPressed: (){
            if(_eventController.text.isEmpty){
              Navigator.pop(context);
              return;
            }
            else{
              if(kEvents[_selectedDay] != null){
                kEvents[_selectedDay]!.add(Appointment(_eventController.text, 'Scheduled'));
                setState((){});
                Navigator.pop(context);
                _eventController.clear();
                return; 
              }
              else{
                List<Appointment> newAppointments = [];
                newAppointments.add(Appointment(_eventController.text, 'Scheduled'));
                DateTime dateTime = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                kEvents[dateTime] = newAppointments;
                _selectedEvents.value = _getEventsForDay(dateTime);
                Navigator.pop(context);
                _eventController.clear();
                return;
              }
            }
          }
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
      ],
    ));
  }
}