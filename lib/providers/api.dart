// ignore_for_file: avoid_print

import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:android/helpers/shared_pref_helper.dart';
import 'package:android/models/appointment.dart';
import 'package:android/models/bill.dart';
import 'package:android/models/custom_http_response.dart';
import 'package:android/models/drug.dart';
import 'package:android/models/patient.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:http/http.dart';

class Api{
  // static const String baseUrl = 'http://10.0.2.2:3000/';
  static const String baseUrl = 'https://techdoc-mathan.herokuapp.com/';
  
  static Future<CustomHttpResponse> loginUser(String username, String password) async {
    var body = {
      "username" : username,
      "password" : password
    };
    CustomHttpResponse customResponse;
    var response = await post(
      Uri.parse(baseUrl + "user/signin"), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: json.encode(body),
    );
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    if(response.statusCode == 200){
      var token = json.decode(response.body)['token'];    
      await SharePreferenceHelper.setUserToken(token);
      customResponse = CustomHttpResponse(json.decode(response.body)['result'],status,[]);
    }
    else{
      customResponse = CustomHttpResponse(json.decode(response.body)['result'],status,[]);
    }
    return customResponse;
  }
  
  static Future<CustomHttpResponse> addDrug(String name, String unit, int cost, int quantity, String token) async {
    var body = {
      "name" : name,
      "cost" : cost,
      "unit" : unit,
      "quantity" : quantity
    };
    CustomHttpResponse customResponse;
    var response = await post(
      Uri.parse(baseUrl + "drug"), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      },
      body: json.encode(body),
    );
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
  
  static Future<CustomHttpResponse> updateDrug(String id, String name, String unit, int cost, int quantity, String token) async {
    var body = {
      "name" : name,
      "cost" : cost,
      "unit" : unit,
      "quantity" : quantity
    };
    CustomHttpResponse customResponse;
    var response = await put(
      Uri.parse(baseUrl + "drug/" + id), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      },
      body: json.encode(body),
    );
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
  
  static Future<CustomHttpResponse> deleteDrug(String id, String token) async {
    CustomHttpResponse customResponse;
    var response = await delete(
      Uri.parse(baseUrl + "drug/" + id), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      }
    );
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
  
  static Future<CustomHttpResponse> addPatient(Patient patient, String token) async {
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
        "weight" : patient.weight,
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
        "weight" : patient.weight,
      };
    }
    CustomHttpResponse customResponse;
    var response = await post(
      Uri.parse(baseUrl + "patient"), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      },
      body: json.encode(body),
    );
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
  
  static Future<CustomHttpResponse> fetchPatients(String token) async {
    List<Patient> patients = [];
    CustomHttpResponse customResponse;
    var url = baseUrl + "patient";
    var response = await http.get(Uri.parse(url), headers : {
      "Authorization" : token
    });
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    if(response.statusCode == 200){
      patients = (json.decode(response.body)['patients'] as List).map((patient) => Patient(patient['id'], patient['name'], patient['dob'], patient['bloodGroup'], patient['gender'], patient['phone'],patient['email'], patient['allergies'], patient['notes'], patient['preferredCommunication'], patient['height'], patient['weight'], (patient['Appointments'] as List).map((appointment) => Appointment(appointment['id'],patient['name'], patient['id'], appointment['status'], DateFormat("yyyy-MM-ddThh:mm:ss.000Z").parse(appointment['datetime']), appointment?['Prescription']?['fileLink'], appointment['notes'], appointment['files'] != null ? appointment['files'].toString().split(',') : [],patient['phone'] ?? patient['email'],patient['preferredCommunication'])).toList())).toList();
      print(patients);
      customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,patients);
    }
    else{
      customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    }
    return customResponse;
  }
  
  static Future<CustomHttpResponse> deletePatient(String id, String token) async {
    CustomHttpResponse customResponse;
    var response = await delete(
      Uri.parse(baseUrl + "patient/" + id), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      }
    );
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
  
  static Future<CustomHttpResponse> updatePatient(Patient patient, String token) async {
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
        "weight" : patient.weight,
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
        "weight" : patient.weight,
      };
    }
    CustomHttpResponse customResponse;
    var response = await put(
      Uri.parse(baseUrl + "patient/" + patient.id), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      },
      body: json.encode(body),
    );
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
  
  static Future<CustomHttpResponse> fetchDrugs(String token) async {
    List<Drug> drugs = [];
    CustomHttpResponse customResponse;
    var url = baseUrl + "drug";
    var response = await http.get(Uri.parse(url), headers : {
      "Authorization" : token
    });
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    if (response.statusCode == 200){
      drugs = (json.decode(response.body)['drugs'] as List).map((drug) => Drug(drug['id'],drug['name'],drug['cost'],drug['unit'], drug['quantity'])).toList();
      customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,drugs);
    }
    else{
      customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    }
    return customResponse;
  }
  
  static Future<CustomHttpResponse> fetchAppointments(String token, DateTime start, DateTime end) async {
    List<Appointment> appointments = [];
    CustomHttpResponse customResponse;
    var url = baseUrl + "appointment?" + "start=" + DateFormat('yyyy-MM-dd').format(start) + " 00:00:00&end=" + DateFormat('yyyy-MM-dd').format(end)+ " 00:00:00";
    var response = await http.get(Uri.parse(url), headers : {
      "Authorization" : token
    });
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    if (response.statusCode == 200){
      appointments = (json.decode(response.body)['appointments'] as List).map((appointment) => Appointment(appointment['id'],appointment['Patient']['name'], appointment['Patient']['id'], appointment['status'], start, appointment['Prescription']['fileLink'], appointment['notes'], appointment['files'] != null ? appointment['files'].toString().split(',') : [],appointment['Patient']['phone'] ?? appointment['Patient']['email'],appointment['Patient']['phone'] ? 'phone' : 'email')).toList();
      customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,appointments);
    }
    else{
      customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    }
    return customResponse;
  }
  
  static Future<CustomHttpResponse> fetchDateAppointments(String token, DateTime date) async {
    List<Appointment> appointments = [];
    CustomHttpResponse customResponse;
    var url = baseUrl + "appointment?" + "start=" + DateFormat('yyyy-MM-dd').format(date) + "T00:00:00&end=" + DateFormat('yyyy-MM-dd').format(date) + "T23:59:59";
    var response = await http.get(Uri.parse(url), headers : {
      "Authorization" : token
    });
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    if (response.statusCode == 200){
      appointments = (json.decode(response.body)['appointments'] as List).map((appointment) => Appointment(appointment['id'],appointment['Patient']['name'], appointment['Patient']['id'], appointment['status'], DateFormat('yyyy-MM-ddThh:mm:ss.000Z').parse(appointment['datetime']), appointment['Prescription']?['fileLink'], appointment['notes'], appointment['files'] != null ? appointment['files'].toString().split(',') : [],appointment['Patient']['phone'] ?? appointment['Patient']['email'],appointment['Patient']['phone'] !=null ? 'phone' : 'email')).toList();
      customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,appointments);
    }
    else{
      customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    }
    return customResponse;
  }
  
  static Future<CustomHttpResponse> fetchAllAppointments(String token) async {
    List<Appointment> appointments = [];
    CustomHttpResponse customResponse;
    var url = baseUrl + "appointment";
    var response = await http.get(Uri.parse(url), headers : {
      "Authorization" : token
    });
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    if (response.statusCode == 200){
      appointments = (json.decode(response.body)['appointments'] as List).map((appointment) => Appointment(appointment['id'],appointment['Patient']['name'], appointment['Patient']['id'], appointment['status'], DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(appointment['datetime']), appointment['Prescription']['fileLink'], appointment['notes'], appointment['files'] != null ? appointment['files'].toString().split(',') : [],appointment['Patient']['phone'] ?? appointment['Patient']['email'],appointment['Patient']['phone'] ? 'phone' : 'email')).toList();
      customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,appointments);
    }
    else{
      customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    }
    return customResponse;
  }
  
  static Future<CustomHttpResponse> addAppointment(Appointment appointment, String token) async {
    CustomHttpResponse customResponse;
    var body = {
      "patientId" : appointment.patientId,
      "date" : {
        "day" :  appointment.date.day,
        "month" : appointment.date.month,
        "year" : appointment.date.year,
        "hours" : appointment.date.hour,
        "minutes" : appointment.date.minute
      }
    };
    print(body);
    var response = await post(
      Uri.parse(baseUrl + "appointment"), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      },
      body: json.encode(body),
    );
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
  
  static Future<CustomHttpResponse> cancelAppointment(String token, int id) async {
    CustomHttpResponse customResponse;
    var url = baseUrl + "appointment/cancel/"+id.toString();
    var response = await http.post(Uri.parse(url), headers : {
      "Authorization" : token
    });
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
  
  static Future<CustomHttpResponse> completeAppointment(String token, int id) async {
    CustomHttpResponse customResponse;
    var url = baseUrl + "appointment/complete/"+id.toString();
    var response = await http.post(Uri.parse(url), headers : {
      "Authorization" : token
    });
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
  
  static Future<CustomHttpResponse> addFiles(String token, int id, List<File> files) async {
    var request = http.MultipartRequest("POST", Uri.parse(baseUrl + "appointment/files/"+id.toString()));
    for (var file in files) {
      String fileName = file.path.split("/").last;
      // var stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
      // var length = await file.length(); 
      // var multipartFileSign = http.MultipartFile('file', stream, length, filename: fileName);
      var multipartFileSign = http.MultipartFile.fromBytes(
        "file",
        file.readAsBytesSync(),
        filename: fileName,
        contentType: MediaType("image", file.path.split(".").last)
      );
      request.files.add(multipartFileSign);
    }
    Map<String, String> headers = {
      "Authorization": token,
      "Content-Type" : 'multipart/form-data'
    };
    request.headers.addAll(headers);
    CustomHttpResponse customResponse;
    var res = await request.send();
    print(res.statusCode);
    var response = await http.Response.fromStream(res);
    print(json.decode(response.body));
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    print(status);
    print(json.decode(response.body)['message']);
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
  
  static Future<CustomHttpResponse> updateAppointment(String token, int id, String note) async {
    var body = {
      "notes" : note      
    };
    CustomHttpResponse customResponse;
    var url = baseUrl + "appointment/update/"+id.toString();
    var response = await post(
      Uri.parse(url), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      },
      body: json.encode(body),
    );
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
  
  static Future<CustomHttpResponse> fetchBills(String token) async {
    List<Bill> bills = [];
    CustomHttpResponse customResponse;
    var url = baseUrl + "bill";
    var response = await http.get(Uri.parse(url), headers : {
      "Authorization" : token
    });
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    if (response.statusCode == 200){
      bills = (json.decode(response.body)['bills'] as List).map((bill) => Bill(bill['Patient']['name'],bill['Patient']['id'],bill['total'],bill['paymentMethod'],bill['fileLink'])).toList();
      customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,bills);
    }
    else{
      customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    }
    return customResponse;
  }
  
  static Future<CustomHttpResponse> addBill(Bill bill, List entries, String token) async{
    CustomHttpResponse customResponse;
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
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
  
  static Future<CustomHttpResponse> addPrescription(String patientId, int appointmentId, List entries, String token) async{
    CustomHttpResponse customResponse;
    var body = {
      "patientId" : patientId,
      "appointmentId" : appointmentId
    };
    List entriesFinal = [];
    for (var entry in entries) {
      entriesFinal.add({
        "name" : entry['name'],
        "schedule" : entry['schedule'],
        "quantity" : entry['quantity'],
        "drugId" : int.parse(entry['drugId'])
      });
    }
    body['entries'] = entriesFinal;
    var response = await post(
      Uri.parse(baseUrl + "prescription"), headers : {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization" : token
      },
      body: json.encode(body),
    );
    var status = json.decode(response.body)['result'] == 'Success' ? true : false;
    customResponse = CustomHttpResponse(json.decode(response.body)['message'],status,[]);
    return customResponse;
  }
}