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
  List drugs = [];
  bool isLoading = false;
  String token = '';
  final nameController = TextEditingController();
  final costController = TextEditingController();
  final unitController = TextEditingController();
  
  @override
  void initState(){
    super.initState();
    fetchDrugs();
  }
  
  fetchDrugs() async {
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        drugs = await Api.fetchDrugs(token);
        token = token;
        setState(() {
          isLoading = false;
        });
      }
    });
  }
  
  addDrug(String name, int cost, String unit) async {
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      var token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        var result = await Api.addDrug(name, unit, cost, token);
        setState(() {
          isLoading = false;
        });
        fetchDrugs();
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
    return ListView.builder(
      itemCount: drugs.length,
      itemBuilder: (context,index){
      return getCard(drugs[index]);
    });
  }
  
  Widget getCard(drug){
    var fullName = drug['name'];
    var email = drug['unit'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          title: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(fullName.toString(), style: const TextStyle(fontSize: 17)),
                  const SizedBox(height: 10,),
                  Text(email.toString(), style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          )
        ),
      )
    );
  }
}