// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:android/components/patient_view.dart';
import 'package:android/helpers/shared_pref_helper.dart';
import 'package:android/models/custom_http_response.dart';
import 'package:android/models/patient.dart';
import 'package:android/providers/api.dart';
import 'package:android/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class PatientsTab extends StatefulWidget {
  const PatientsTab({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  PatientsTabState createState() => PatientsTabState();
}

class PatientsTabState extends State<PatientsTab> with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  
  List<Patient> patients = [];
  String token = '';
  bool isLoading = false;
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final bloodGroupController = TextEditingController();
  final genderController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final allergiesController = TextEditingController();
  final notesController = TextEditingController();
  final preferredCommuncationController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    fetchPatients();
    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
  }
  
  addPatient(Patient patient){
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        var customHttpResponse = await Api.addPatient(patient, token);
        setState(() {
          isLoading = false;
        });
        Alert(
          context: context,
          style: FitnessAppTheme.alertStyle,
          buttons: [
            DialogButton(
              child: Text("Ok",style: TextStyle(color: Colors.white, fontSize: 20),),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
          title: customHttpResponse.message,
        ).show();
        if(customHttpResponse.status){
          fetchPatients();
        }
      }
    });
  }
  
  updatePatient(Patient patient) async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customHttpResponse = await Api.updatePatient(patient, token);
        setState(() {
          isLoading = false;
        });
        Alert(
          context: context,
          style: FitnessAppTheme.alertStyle,
          buttons: [
            DialogButton(
              child: Text("Ok",style: TextStyle(color: Colors.white, fontSize: 20),),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
          title: customHttpResponse.message,
        ).show();
        if(customHttpResponse.status){          
          fetchPatients();
        }
      }
    });
  }

  showUpdateDialog(Patient patient) async {
    nameController.text = patient.name;
    dobController.text = patient.dob;
    bloodGroupController.text = patient.bloodGroup;
    genderController.text = patient.gender;
    phoneController.text = patient.phone ?? '';
    emailController.text = patient.email ?? '';
    allergiesController.text = patient.allergies ?? '';
    notesController.text = patient.notes ?? '';
    preferredCommuncationController.text = patient.preferredCommunication;
    heightController.text = patient.height.toString();
    weightController.text = patient.weight.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text('Update Patient ' + patient.name),
          content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',                
                  ),
                ),
                TextFormField(
                  controller: dobController,
                  decoration: const InputDecoration(
                    labelText: 'D.O.B'
                  ),
                ),
                TextFormField(
                  controller: bloodGroupController,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                  ),
                ),
                TextFormField(
                  controller: genderController,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                  ),
                ),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                  ),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextFormField(
                  controller: allergiesController,
                  decoration: const InputDecoration(
                    labelText: 'Allergies',
                  ),
                ),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                  ),
                ),
                TextFormField(
                  controller: preferredCommuncationController,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Communication',
                  ),
                ),
                TextFormField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height',
                  ),
                ),
                TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () async { 
              String name = nameController.text;
              String dob = dobController.text;
              String bloodGroup = bloodGroupController.text;
              String gender = genderController.text;
              String phone = phoneController.text;
              String email = emailController.text;
              String allergies = allergiesController.text;
              String notes = notesController.text;
              String preferredCommunication = preferredCommuncationController.text;
              int height = int.parse(heightController.text);
              int weight = int.parse(weightController.text);
              Patient updatedPatient = Patient(patient.id,name, dob, bloodGroup, gender, phone, email, allergies, notes, preferredCommunication, height, weight,[]);
              if (name != ''){
                Navigator.pop(context);
                await updatePatient(updatedPatient);
              }
            },
            child: const Text('Submit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            }, 
            child: const Text('Cancel')
          )
        ],
      );
    });
  }


  showAddDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Add Patient'),
          content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',                
                  ),
                ),
                TextFormField(
                  controller: dobController,
                  decoration: const InputDecoration(
                    labelText: 'D.O.B'
                  ),
                ),
                TextFormField(
                  controller: bloodGroupController,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                  ),
                ),
                TextFormField(
                  controller: genderController,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                  ),
                ),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                  ),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextFormField(
                  controller: allergiesController,
                  decoration: const InputDecoration(
                    labelText: 'Allergies',
                  ),
                ),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                  ),
                ),
                TextFormField(
                  controller: preferredCommuncationController,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Communication',
                  ),
                ),
                TextFormField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height',
                  ),
                ),
                TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () async { 
              String name = nameController.text;
              String dob = dobController.text;
              String bloodGroup = bloodGroupController.text;
              String gender = genderController.text;
              String phone = phoneController.text;
              String email = emailController.text;
              String allergies = allergiesController.text;
              String notes = notesController.text;
              String preferredCommunication = preferredCommuncationController.text;
              int height = int.parse(heightController.text);
              int weight = int.parse(weightController.text);
              Patient patient = Patient('fakeId',name, dob, bloodGroup, gender, phone, email, allergies, notes, preferredCommunication, height, weight,[]);
              if (name != ''){
                Navigator.pop(context);
                await addPatient(patient);
              }
            },
            child: const Text('Submit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            }, 
            child: const Text('Cancel')
          )
        ],
      );
    });
  }
  
  showDeleteDialog(patient) async{
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text('Delete Patient ' + patient.name),          
          actions: [
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () async {               
                Navigator.pop(context);
                await deletePatient(patient.id);
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              }, 
              child: const Text('Cancel')
            )
          ],
        );
      }
    );
  }
  
  deletePatient(String id) async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customHttpResponse = await Api.deletePatient(id, token);
        setState(() {
          isLoading = false;
        });
        Alert(
          context: context,
          style: FitnessAppTheme.alertStyle,
          buttons: [
            DialogButton(
              child: Text("Ok",style: TextStyle(color: Colors.white, fontSize: 20),),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
          title: customHttpResponse.message,
        ).show();
        if(customHttpResponse.status){          
          fetchPatients();
        }
      }
    });
  }
  
  Future<void> fetchPatients() async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customHttpResponse = await Api.fetchPatients(token);
        token = token;
        if(customHttpResponse.status){
          patients = customHttpResponse.items.cast();
          addAllListData(patients);
        }
        else{
          Alert(
            context: context,
            style: FitnessAppTheme.alertStyle,
            buttons: [
              DialogButton(
                child: Text("Ok",style: TextStyle(color: Colors.white, fontSize: 20),),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
            title: customHttpResponse.message,
          ).show();
        }
        setState(() {
          isLoading = false;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: getBody()
      ),
    );
  }
  
  Widget getBody(){
    if(isLoading){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    else{
      return RefreshIndicator(
        child: Stack(
          children: <Widget>[
            getMainListViewUI(),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
        onRefresh: fetchPatients
      );
    }
  }
  
  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: FitnessAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 30 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text(
                                  'Patients',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                                onTap: () {
                                  showMenu<String>(
                                    context: context,
                                    position: RelativeRect.fromLTRB(25.0, 25.0, 0.0, 0.0),      //position where you want to show the menu on screen
                                    items: [                                      
                                      PopupMenuItem<String>(child: const Text('Settings')),
                                      PopupMenuItem<String>(child: const Text('Logout'), onTap: () async {
                                        await SharePreferenceHelper.logout();
                                        Navigator.pushReplacementNamed(context, '/login');
                                      })
                                    ],
                                    elevation: 8.0,
                                  );
                                },
                                child: Center(
                                  child: Icon(
                                    Icons.more_vert_outlined                                    
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
  
  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }
  
  void addAllListData(List<Patient> patients) {
    listViews.clear();

    for(int i=0;i<patients.length;i++){
      listViews.add(
        PatientView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: widget.animationController!,
              curve: Interval((1 / 9) * 5, 1.0, curve: Curves.fastOutSlowIn)
            )
          ),
          animationController: widget.animationController!,
          patient: patients[i],
          deletePatient: showDeleteDialog,
          updatePatient: showUpdateDialog,
        ),
      );
    }    
    
  }
  
}
