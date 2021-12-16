// ignore_for_file: must_be_immutable, no_logic_in_create_state, use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/appointments.dart';
import 'pages/bills.dart';
import 'pages/profile.dart';
import 'pages/patients.dart';
import 'pages/drugs.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const LoginPage(),
      '/appointments': (context) => const AppointmentPage(),
      '/profile' : (context) => const ProfilePage(),
      '/bills' : (context) => const BillPage(),
      '/drugs' : (context) => const DrugPage(),
      '/patients' : (context) => const PatientPage()
    },
  )
);
