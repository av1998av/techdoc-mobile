// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:android/components/appointment_view.dart';
import 'package:android/components/drug_view.dart';
import 'package:android/helpers/shared_pref_helper.dart';
import 'package:android/models/custom_http_response.dart';
import 'package:android/models/drug.dart';
import 'package:android/providers/api.dart';
import 'package:android/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DrugsTab extends StatefulWidget {
  const DrugsTab({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  DrugsTabState createState() => DrugsTabState();
}

class DrugsTabState extends State<DrugsTab> with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  final nameController = TextEditingController();
  final costController = TextEditingController();
  final unitController = TextEditingController();
  final nameEditController = TextEditingController();
  final costEditController = TextEditingController();
  final unitEditController = TextEditingController();

  List<Drug> drugs = [];
  bool isLoading = false;
  String token = '';

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    
    fetchDrugs();
    // addAllListData();
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
  
  showAddDialog() async{
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Add Drug/Process'),
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
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit'
                  ),
                ),
                TextFormField(
                  controller: costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
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
              String unit = unitController.text;
              int cost = int.parse(costController.text);
              if (name != ''){
                Navigator.pop(context);
                await addDrug(name, cost, unit);
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
  
  showUpdateDialog(drug) async{
    nameEditController.text = drug.name;
    costEditController.text = drug.cost.toString();
    unitEditController.text = drug.unit;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Update Drug/Process'),
          content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: nameEditController,
                  decoration: const InputDecoration(
                    labelText: 'Name',                
                  ),
                ),
                TextFormField(
                  controller: unitEditController,
                  decoration: const InputDecoration(
                    labelText: 'Unit'
                  ),
                ),
                TextFormField(
                  controller: costEditController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
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
              String name = nameEditController.text;
              String unit = unitEditController.text;
              int cost = int.parse(costEditController.text);
              if (name != ''){
                Navigator.pop(context);
                await updateDrug(drug.id.toString(), name, cost, unit);
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
  
  showDeleteDialog(drug) async{
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text('Delete Drug/Process ' + drug.name),          
          actions: [
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () async {               
                Navigator.pop(context);
                await deleteDrug(drug.id.toString());
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
  
  addDrug(String name, int cost, String unit) async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customHttpResponse = await Api.addDrug(name, unit, cost, token);
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
          fetchDrugs();
        }
      }
    });
  }
  
  updateDrug(String id, String name, int cost, String unit) async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customHttpResponse = await Api.updateDrug(id, name, unit, cost, token);
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
          fetchDrugs();
        }
      }
    });
  }
  
  deleteDrug(String id) async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        customHttpResponse = await Api.deleteDrug(id, token);
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
          fetchDrugs();
        }
      }
    });
  }
  
  Future<void> fetchDrugs() async {
    CustomHttpResponse customHttpResponse;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        token = token;
        customHttpResponse = await Api.fetchDrugs(token);
        if(customHttpResponse.status){
          drugs = customHttpResponse.items.cast();
          addAllListData(drugs);
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
        onRefresh: fetchDrugs
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
                                  'Drugs/Processes',
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
  
  void addAllListData(List<Drug> drugs) {
    listViews.clear();

    for(int i=0;i<drugs.length;i++){
      listViews.add(
        DrugView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: widget.animationController!,
              curve: Interval((1 / 9) * 5, 1.0, curve: Curves.fastOutSlowIn)
            )
          ),
          animationController: widget.animationController!,
          drug: drugs[i],
          updateDrug : showUpdateDialog,
          deleteDrug : showDeleteDialog
        ),
      );
    }
    
  }
  
}
