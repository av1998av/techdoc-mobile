import 'package:android/models/bill.dart';
import 'package:flutter/material.dart';
import 'package:android/helpers/shared_pref_helper.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android/providers/api.dart';
import '../navbar.dart';

class BillPage extends StatefulWidget {
  const BillPage({Key? key}) : super(key: key);

  @override
  BillPageState createState() => BillPageState();
}

class BillPageState extends State<BillPage> {
  List<Bill> bills = [];
  bool isLoading = false;
  
  @override
  void initState(){
    super.initState();
    fetchBills();
  }
  
  fetchBills() async {
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 3), () async {
      final token = await SharePreferenceHelper.getUserToken();
      if(token != ''){
        bills = await Api.fetchBills(token);
        setState(() {
          bills = bills;
          isLoading = false;
        });
      }
    });
  }
  
  Future<void> openBrowser(String url) async {
    if (!await launch(url,forceSafariVC: false,forceWebView: false)) {
      throw 'Could not launch $url';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients')
      ),
      body: getBody(),
      floatingActionButton: FloatingActionButton(onPressed: () {  },),
      drawer: const NavBar(),
    );
  }
  Widget getBody(){
    if(bills.contains(null) || bills.isEmpty || isLoading){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (context,index){
      return getCard(bills[index]);
    });
  }
  Widget getCard(Bill bill){
    var fullName = bill.name;
    var total = bill.total;
    var link = bill.fileLink;
    var method = bill.paymentMethod;
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
                  Text(total.toString(), style: const TextStyle(color: Colors.grey)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      openBrowser(link);
                    },
                    child: const Icon(Icons.download_rounded, color: Colors.white),
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