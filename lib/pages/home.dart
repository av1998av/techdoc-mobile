import 'package:android/tabs/appointments.dart';
import 'package:android/tabs/bills.dart';
import 'package:android/tabs/drugs.dart';
import 'package:android/tabs/patients.dart';
import 'package:flutter/material.dart';
import 'package:android/themes/icons.dart';
import 'package:android/themes/themes.dart';
import 'package:android/components/bottom_navig.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  AnimationController? animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  final GlobalKey<AppointmentsTabState> appointmentsTabState = GlobalKey<AppointmentsTabState>();
  final GlobalKey<DrugsTabState> drugsTabState = GlobalKey<DrugsTabState>();
  final GlobalKey<PatientsTabState> patientsTabState = GlobalKey<PatientsTabState>();
  final GlobalKey<BillsTabState> billsTabState = GlobalKey<BillsTabState>();

  Widget tabBody = Container(
    color: FitnessAppTheme.background,
  );

  @override
  void initState() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = AppointmentsTab(animationController: animationController,key: appointmentsTabState);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                  bottomBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {
            tabIconsList.forEach((TabIconData tab) {
              if(tab.name == 'Appointments' && tab.isSelected){
                 appointmentsTabState.currentState!.showAddDialog();
              }
              else if(tab.name == 'Drugs' && tab.isSelected){
                 drugsTabState.currentState!.showAddDialog();
              }
              else if(tab.name == 'Bills' && tab.isSelected){
                 billsTabState.currentState!.showAddDialog();
              }
              else if(tab.name == 'Patients' && tab.isSelected){
                 patientsTabState.currentState!.showAddDialog();
              }
            });            
          },
          changeIndex: (int index) {
            if(index == 0){
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      AppointmentsTab(animationController: animationController,key: appointmentsTabState);
                });
              });
            }
            else if(index == 1){
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      DrugsTab(animationController: animationController,key: drugsTabState);
                });
              });
            }
            else if(index == 2){
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      PatientsTab(animationController: animationController,key: patientsTabState);
                });
              });
            }
            else if(index == 3){
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      BillsTab(animationController: animationController,key: billsTabState);
                });
              });
            }
          },
        ),
      ],
    );
  }
}
