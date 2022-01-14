// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:android/components/bill_view.dart';
import 'package:android/helpers/shared_pref_helper.dart';
import 'package:android/models/bill.dart';
import 'package:android/models/custom_http_response.dart';
import 'package:android/models/drug.dart';
import 'package:android/models/patient.dart';
import 'package:android/providers/api.dart';
import 'package:android/themes/themes.dart';
import 'package:android/components/counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class BillsTab extends StatefulWidget {
  const BillsTab({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  BillsTabState createState() => BillsTabState();
}

class BillsTabState extends State<BillsTab> with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  
  List<Bill> bills = [];
  List<Patient> patients = [];
  List<Drug> drugs = [];
  bool isLoading = false;
  late int numberOfItems;
  final numberNotif = ValueNotifier<int>(0);

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;
  
  final TextEditingController patientController = TextEditingController();
  final List<TextEditingController> drugControllers = List.generate(10, (i) => TextEditingController());
  final List<TextEditingController> priceControllers = List.generate(10, (i) => TextEditingController());
  final List<TextEditingController> quantityControllers = List.generate(10, (i) => TextEditingController());
  final List<TextEditingController> costControllers = List.generate(10, (i) => TextEditingController());
  
  List<Patient> getPatientSuggestions(pattern) {
    return patients.where((patient) => patient.name.toLowerCase().contains(pattern)).toList();
  }
  
  List<Drug> getDrugSuggestions(pattern) {
    return drugs.where((drug) => drug.name.toLowerCase().contains(pattern)).toList();
  }

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    fetchBills();
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
  
  Future<void> fetchBills() async {
    CustomHttpResponse customBillsHttpResponse;
    CustomHttpResponse customPatientsHttpResponse;
    CustomHttpResponse customDrugsHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      final token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customBillsHttpResponse = await Api.fetchBills(token);
        customPatientsHttpResponse = await Api.fetchPatients(token);      
        customDrugsHttpResponse = await Api.fetchDrugs(token);
        if(customBillsHttpResponse.status && customPatientsHttpResponse.status && customDrugsHttpResponse.status){
          patients = customPatientsHttpResponse.items.cast();
          drugs = customDrugsHttpResponse.items.cast();
          bills = customBillsHttpResponse.items.cast();
          addAllListData(bills);
        }
        else{
          String message = '';
          if(customBillsHttpResponse.status){
            message = customBillsHttpResponse.message;
          }
          else if(customPatientsHttpResponse.status){
            message = customPatientsHttpResponse.message;
          }
          else{
            message = customDrugsHttpResponse.message;
          }
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    }, 
                    child: const Text('OK')
                  )
                ],
              );
            }
          );
        }
        setState(() {
          bills = bills;
          isLoading = false;
        });
      }
    });
  }

  addBill (Bill bill, List entries) async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customHttpResponse = await Api.addBill(bill, entries, token);
        token = token;
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(customHttpResponse.message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  }, 
                  child: const Text('OK')
                )
              ],
            );
          }
        );
        if(customHttpResponse.status){          
          fetchBills();
        }
      }
    });
  }

  showAddDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(10),
        title: Text("New Bill"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width*0.75,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              child: Column(
                children: <Widget>[
                  TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: InputDecoration(
                        labelText: 'Patient',
                        border: OutlineInputBorder()
                      ),
                      controller: patientController
                    ),
                    suggestionsCallback: (pattern) async {
                      return getPatientSuggestions(pattern);
                    },
                    itemBuilder: (context, Patient patient) {
                      return ListTile(
                        title: Text(patient.name),
                        subtitle: Text(patient.id)
                      );
                    }, 
                    onSuggestionSelected: (Patient patient) {
                      patientController.text = patient.id;
                    },
                  ),
                  const SizedBox(height: 10,),
                  NumericStepButton(
                    maxValue: 20,
                    minValue: 1,
                    current: max(1,numberNotif.value),
                    onChanged: (value) {
                      numberNotif.value = value;                      
                    },
                  ),
                  ValueListenableBuilder(valueListenable: numberNotif, builder: (context, int value, widget){
                    return Column(
                      children: <Widget>[
                        for (int i=0;i<max(value,1);i++) Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top:10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.lightBlue
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          child: getForm(i)
                        )
                      ]
                    );
                  }),
                ],
              )
            )
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Ok"),
            onPressed: () {
              Navigator.pop(context);
              List entries = [];
              int total = 0;
              var list = Iterable<int>.generate(max(numberNotif.value,1)).toList();
              for (var item in list) {
                total = total + int.parse(priceControllers[item].text);
                entries.add({
                  "name" : '',
                  "cost" : priceControllers[item].text,
                  "quantity" : quantityControllers[item].text,
                  "drugId" : drugControllers[item].text
                });
              }
              addBill(Bill('',patientController.text,total,'CASH',''),entries);
            }
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ],
      ),
    );
  }

  Widget getForm(int index){    
    return Column(
      children: <Widget>[
        TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
            decoration: InputDecoration(
              labelText: 'Drug/Process',
              border: OutlineInputBorder()
            ),
            controller: drugControllers[index]
          ),
          suggestionsCallback: (pattern) async {
            return getDrugSuggestions(pattern);
          },
          itemBuilder: (context, Drug drug) {
            return ListTile(
              title: Text(drug.name),
              subtitle: Text(drug.unit)
            );
          }, 
          onSuggestionSelected: (Drug drug) {
            drugControllers[index].text = drug.id.toString();
            costControllers[index].text = drug.cost.toString();
          },
        ),
        const SizedBox(height: 10,),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Cost',
            border: OutlineInputBorder(),
          ),
          controller: costControllers[index],
        ),
        const SizedBox(height: 10,),
        TextFormField(
          onChanged: (text){
            priceControllers[index].text = (int.parse(costControllers[index].text) * int.parse(text)).toString();
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder()
          ),
          controller: quantityControllers[index],
        ),
        const SizedBox(height: 10,),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Price',
            border: OutlineInputBorder()
          ),
          controller: priceControllers[index],
        ),
      ]
    );
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
        onRefresh: fetchBills
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
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  5,
              bottom: 62 
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
                                  'Bills',
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
  
  void addAllListData(List<Bill> bills) {
    listViews.clear();

    for(int i=0;i<bills.length;i++){
      listViews.add(
        BillView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: widget.animationController!,
              curve: Interval((1 / 9) * 5, 1.0, curve: Curves.fastOutSlowIn)
            )
          ),
          animationController: widget.animationController!,
          bill: bills[i],
        ),
      );
    }
    
  }
  
}
