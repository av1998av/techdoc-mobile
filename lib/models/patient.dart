import 'package:android/models/appointment.dart';

class Patient {
  final String id;
  final String name;
  final String dob;
  final String bloodGroup;
  final String gender;
  final String? phone;
  final String? email;
  final String? allergies;
  final String? notes;
  final String preferredCommunication;
  final int height;
  final int weight;
  final List<Appointment> appointments;
  
  const Patient(this.id, this.name, this.dob, this.bloodGroup, this.gender, this.phone, this.email, this.allergies, this.notes, this.preferredCommunication, this.height, this.weight, this.appointments) ;
  
}