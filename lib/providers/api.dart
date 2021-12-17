import 'package:android/helpers/shared_pref_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Api{
  
  static const String baseUrl = 'http://localhost:3000/';
  
  static Future<void> loginUser() async {
    String token = "random string";
    await SharePreferenceHelper.setUserToken(token);
  }
  
  static Future<List> fetchPatients() async {
    List patients = [];
    var url = baseUrl + "patients";
    var response = await http.get(Uri.parse(url));
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