// ignore_for_file: avoid_print

import 'package:android/helpers/shared_pref_helper.dart';
import 'package:android/models/appointment.dart';
import 'package:android/models/bill.dart';
import 'package:android/models/drug.dart';
import 'package:android/models/patient.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:http/http.dart';

class Api{
  
  static const String baseUrl = 'http://10.0.2.2:3000/';
  
  static Future<void> loginUser(String username, String password) async {
    var body = {
      "username" : username,
      "password" : password
    };
    var response = await post(
      Uri.parse(baseUrl + "user/signin"), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200){
      var token = json.decode(response.body)['token'];    
      await SharePreferenceHelper.setUserToken(token);  
    }
  }
  
  static Future<bool> addDrug(String name, String unit, int cost, String token) async {
    var body = {
      "name" : name,
      "cost" : cost,
      "unit" : unit
    };
    var response = await post(
      Uri.parse(baseUrl + "drug"), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200){
      return true; 
    }
    else{
      return false;
    }
  }
  
  static Future<bool> addPatient(Patient patient, String token) async {
    var body = {};
    if(patient.preferredCommunication == 'email'){
      body = {
        "name" : patient.name,
        "dob" : patient.dob,
        "bloodGroup" : patient.bloodGroup,
        "preferredCommunication" : patient.preferredCommunication,
        "gender" : patient.gender,
        "email" : patient.email,
        "allergies" : patient.allergies,
        "notes" : patient.notes,
        "height" : patient.height,
        "weight" : patient.height,
      };
    }
    else if(patient.preferredCommunication == 'phone'){
      body = {
        "name" : patient.name,
        "dob" : patient.dob,
        "bloodGroup" : patient.bloodGroup,
        "preferredCommunication" : patient.preferredCommunication,
        "gender" : patient.gender,
        "phone" : patient.phone,
        "allergies" : patient.allergies,
        "notes" : patient.notes,
        "height" : patient.height,
        "weight" : patient.height,
      };
    }
    var response = await post(
      Uri.parse(baseUrl + "patient"), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200){
      return true; 
    }
    else{
      return false;
    }
  }
  
  static Future<List<Patient>> fetchPatients(String token) async {
    List<Patient> patients = [];
    var url = baseUrl + "patient";
    var response = await http.get(Uri.parse(url), headers : {
      "Authorization" : token
    });
    if (response.statusCode == 200){
      patients = (json.decode(response.body)['patients'] as List).map((patient) => Patient(patient['id'], patient['name'], patient['dob'], patient['bloodGroup'], patient['gender'], patient['phone'], patient['email'], patient['allergies'], patient['notes'], patient['preferredCommunication'], patient['height'], patient['weight'])).toList();
    }
    return patients;
  }
  
  static Future<List<Drug>> fetchDrugs(String token) async {
    List<Drug> drugs = [];
    var url = baseUrl + "drug";
    var response = await http.get(Uri.parse(url), headers : {
      "Authorization" : token
    });
    if (response.statusCode == 200){
      drugs = (json.decode(response.body)['drugs'] as List).map((drug) => Drug(drug['id'],drug['name'],drug['cost'],drug['unit'])).toList();
    }
    return drugs;
  }
  
  static Future<List<Appointment>> fetchAppointments(String token, DateTime start, DateTime end) async {
    List<Appointment> appointments = [];
    var url = baseUrl + "appointment?" + "start=" + DateFormat('yyyy-MM-dd').format(start) + " 00:00:00&end=" + DateFormat('yyyy-MM-dd').format(end)+ " 00:00:00";
    var response = await http.get(Uri.parse(url), headers : {
      "Authorization" : token
    });
    if (response.statusCode == 200){
      appointments = (json.decode(response.body)['appointments'] as List).map((appointment) => Appointment(appointment['id'],appointment['Patient']['name'], appointment['Patient']['id'], appointment['status'], start)).toList();
    }
    return appointments;
  }
  
  static Future<List<Appointment>> fetchAllAppointments(String token) async {
    List<Appointment> appointments = [];
    var url = baseUrl + "appointment";
    var response = await http.get(Uri.parse(url), headers : {
      "Authorization" : token
    });
    if (response.statusCode == 200){
      appointments = (json.decode(response.body)['appointments'] as List).map((appointment) => Appointment(appointment['id'],appointment['Patient']['name'], appointment['Patient']['id'], appointment['status'], DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(appointment['datetime']))).toList();
    }
    
    return appointments;
  }
  
  static Future<bool> addAppointment(Appointment appointment, String token) async {
    var body = {
      "patientId" : appointment.patientId,
      "date" : {
        "day" :  appointment.date.day,
        "month" : appointment.date.month,
        "year" : appointment.date.year
      }
    };
    var response = await post(
      Uri.parse(baseUrl + "appointment"), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200){
      return true; 
    }
    else{
      return false;
    }
  }
  
  static Future<bool> cancelAppointment(String token, int id) async {
    var url = baseUrl + "appointment/cancel/"+id.toString();
    var response = await http.post(Uri.parse(url), headers : {
      "Authorization" : token
    });
    if (response.statusCode == 200){
      return true;
    }
    else{
      return false;
    }
  }
  
  static Future<bool> completeAppointment(String token, int id) async {
    var url = baseUrl + "appointment/complete/"+id.toString();
    var response = await http.post(Uri.parse(url), headers : {
      "Authorization" : token
    });
    if (response.statusCode == 200){
      return true;
    }
    else{
      return false;
    }
  }
  
  static Future<List<Bill>> fetchBills(String token) async {
    List<Bill> bills = [];
    var url = baseUrl + "bill";
    var response = await http.get(Uri.parse(url), headers : {
      "Authorization" : token
    });
    if (response.statusCode == 200){
      bills = (json.decode(response.body)['bills'] as List).map((bill) => Bill(bill['Patient']['name'],bill['Patient']['id'],bill['total'],bill['paymentMethod'],bill['fileLink'])).toList();
    }
    return bills;
  }
  
  static Future<bool> addBill(Bill bill, List entries, String token) async{
    var body = {
      "patientId" : bill.patientId,
      "total" : bill.total,
      "paymentMethod" : bill.paymentMethod
    };
    List entriesFinal = [];
    for (var entry in entries) {
      entriesFinal.add({
        "name" : entry['name'],
        "cost" : entry['cost'],
        "quantity" : entry['quantity'],
        "drugId" : int.parse(entry['drugId'])
      });
    }
    body['entries'] = entriesFinal;
    var response = await post(
      Uri.parse(baseUrl + "bill"), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200){
      return true; 
    }
    else{
      return false;
    }
  }
}