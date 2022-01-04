import 'package:android/models/custom_http_response.dart';
import 'package:android/models/drug.dart';
import 'package:flutter/material.dart';
import 'package:android/helpers/shared_pref_helper.dart';
import 'package:android/providers/api.dart';
import '../navbar.dart';

class DrugPage extends StatefulWidget {
  const DrugPage({Key? key}) : super(key: key);

  @override
  DrugPageState createState() => DrugPageState();
}

class DrugPageState extends State<DrugPage> {
  List<Drug> drugs = [];
  bool isLoading = false;
  String token = '';
  final nameController = TextEditingController();
  final costController = TextEditingController();
  final unitController = TextEditingController();
  final nameEditController = TextEditingController();
  final costEditController = TextEditingController();
  final unitEditController = TextEditingController();
  
  @override
  void initState(){
    super.initState();
    fetchDrugs();
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
        }
        else{
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
        }
        setState(() {
          isLoading = false;
        });
      }
    });
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
          fetchDrugs();
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drugs')
      ),
      body: getBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () => {          
          showDialog(
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
          })
        }
      ),
      drawer: const NavBar(),
    );
  }
  
  Widget getBody(){
    if(drugs.contains(null) || drugs.isEmpty || isLoading){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return RefreshIndicator(
      child: ListView.builder(
        itemCount: drugs.length,
        itemBuilder: (context,index){
          return getCard(drugs[index]); 
        }
      ),
      onRefresh: fetchDrugs
    );
  }
  
  Widget getCard(Drug drug){
    var fullName = drug.name;
    var email = drug.unit;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(fullName.toString(), style: const TextStyle(fontSize: 17)),
                  const SizedBox(height: 10,),
                  Text(email.toString(), style: const TextStyle(color: Colors.grey)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
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
                    },
                    child: const Icon(Icons.edit, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                      primary: Colors.blue, // <-- Button color
                      onPrimary: Colors.red, // <-- Splash color
                    ),
                  )
                ],
              )
            ],
          )
        ),
      )
    );
  }
}