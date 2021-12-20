import 'dart:collection';

class Appointment {
  final String patientName;
  final String status;
  final DateTime date;

  const Appointment(this.patientName, this.status, this.date);
  
  @override
  String toString() {
    return patientName;
  }
}

LinkedHashMap<DateTime, List<Appointment>> appointments = LinkedHashMap<DateTime, List<Appointment>>();


List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);