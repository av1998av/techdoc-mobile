import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/appointments.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const LoginPage(),
      '/appointments': (context) => const AppointmentPage(),
    },
  )
);
