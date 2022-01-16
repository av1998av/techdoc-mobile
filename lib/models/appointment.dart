import 'dart:collection';

class Appointment {
  final String patientName;
  final String patientId;
  final String status;
  final DateTime date;
  final int id;
  final String? prescriptionFileLink;
  final String? notes;

  const Appointment(this.id, this.patientName, this.patientId, this.status, this.date, this.prescriptionFileLink,this.notes);
  
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