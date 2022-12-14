import 'package:android/pages/home.dart';
import 'pages/login.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/login',
    routes: {
      '/login': (context) => const LoginPage(),
      '/home': (context) => HomePage()
    },
  )
);