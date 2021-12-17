// ignore_for_file: avoid_print

import 'package:android/helpers/shared_pref_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http/http.dart';

class Api{
  
  static const String baseUrl = 'http://10.0.2.2:3000/';
  
  static Future<void> loginUser(String username, String password) async {
    var body = {
      "username" : username,
      "password" : password
    };
    print(body);
    var response = await post(
      Uri.parse(baseUrl + "user/signin"), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: json.encode(body),
    );
    print(json.decode(response.body));
    if(response.statusCode == 200){
      var token = json.decode(response.body)['token'];    
      await SharePreferenceHelper.setUserToken(token);  
    }
  }
  
  static Future<List> fetchPatients(String token) async {
    List patients = [];
    var url = baseUrl + "patient";
    var response = await http.get(Uri.parse(url), headers : {
      "Authorization" : token
    });
    if (response.statusCode == 200){
      patients = json.decode(response.body)['patients'];
    }
    return patients;
  }
  
  static Future<List> fetchDrugs() async {
    List drugs = [];
    var url = baseUrl + "drugs";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200){
      drugs = json.decode(response.body)['drugs'];
    }
    return drugs;
  }
  
  static Future<List> fetchAppointments() async {
    List appointments = [];
    var url = baseUrl + "appointments";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200){
      appointments = json.decode(response.body)['appointments'];
    }
    return appointments;
  }
  
  static Future<List> fetchBills() async {
    List bills = [];
    var url = baseUrl + "bills";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200){
      bills = json.decode(response.body)['bills'];
    }
    return bills;
  }
}