// // ignore_for_file: must_be_immutable, no_logic_in_create_state, use_key_in_widget_constructors
// import 'package:flutter/material.dart';
// import 'pages/login.dart';
// import 'pages/appointments.dart';
// import 'pages/bills.dart';
// import 'pages/profile.dart';
// import 'pages/patients.dart';
// import 'pages/drugs.dart';

// void main() => runApp(
//   MaterialApp(
//     debugShowCheckedModeBanner: false,
//     initialRoute: '/',
//     routes: {
//       '/': (context) => const LoginPage(),
//       '/appointments': (context) => const AppointmentPage(),
//       '/profile' : (context) => const ProfilePage(),
//       '/bills' : (context) => const BillPage(),
//       '/drugs' : (context) => const DrugPage(),
//       '/patients' : (context) => const PatientPage()
//     },
//   )
// );

// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:android/pages/test1.dart';
import 'package:android/pages/test2.dart';
import 'package:android/pages/test3.dart';
import 'package:android/pages/test4.dart';
import 'package:flutter/material.dart';
import 'package:android/themes/icons.dart';
import 'package:android/themes/themes.dart';
import 'package:android/components/bottom_navig.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FitnessAppHomeScreen(),
  )
);

class FitnessAppHomeScreen extends StatefulWidget {
  @override
  _FitnessAppHomeScreenState createState() => _FitnessAppHomeScreenState();
}

class _FitnessAppHomeScreenState extends State<FitnessAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(
    color: FitnessAppTheme.background,
  );

  @override
  void initState() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = Test(animationController: animationController);
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
          addClick: () {},
          changeIndex: (int index) {
            if(index == 0){
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      Test(animationController: animationController);
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
                      Test2(animationController: animationController);
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
                      Test3(animationController: animationController);
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
                      Test4(animationController: animationController);
                });
              });
            }
          },
        ),
      ],
    );
  }
}
