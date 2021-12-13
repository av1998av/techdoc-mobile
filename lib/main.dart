import 'package:flutter/material.dart';
import 'pages/login.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const LoginPage()
    },
  )
);
