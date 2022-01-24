import 'package:flutter/material.dart';

class TabIconData {
  TabIconData({
    this.index = 0,
    this.isSelected = false,
    this.name = '',
    this.icon = const Icon(Icons.timelapse_sharp),
    this.selectedIcon = const Icon(Icons.timelapse_sharp),
    this.animationController,
  });

  Icon icon;
  Icon selectedIcon;
  String name;
  bool isSelected;
  int index;

  AnimationController? animationController;

  static List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      name: 'Appointments',
      index: 0,
      isSelected: true,
      animationController: null,
      icon: const Icon(Icons.timelapse_sharp, size: 30.0,),
      selectedIcon: Icon(Icons.timelapse_sharp, size:40, color: Colors.deepOrange.shade600,)
    ),
    TabIconData(
      name: 'Drugs',
      index: 1,
      isSelected: false,
      animationController: null,
      icon: const Icon(Icons.medical_services_outlined, size: 30.0,),
      selectedIcon: Icon(Icons.medical_services_outlined, size:40, color: Colors.deepOrange.shade600,)
    ),
    TabIconData(
      name: 'Patients',
      index: 2,
      isSelected: false,
      animationController: null,
      icon: const Icon(Icons.person, size: 30.0,),
      selectedIcon: Icon(Icons.person, size:40, color: Colors.deepOrange.shade600,)
    ),
    TabIconData(
      index: 3,
      name: 'Bills',
      isSelected: false,
      animationController: null,
      icon: const Icon(Icons.monetization_on, size: 30.0,),
      selectedIcon: Icon(Icons.monetization_on, size:40, color: Colors.deepOrange.shade600,)
    ),
  ];
}
