// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import '../themes/themes.dart';
import 'bottom_navig.dart';

class BirthdaysView extends StatelessWidget{
  
  const BirthdaysView({Key? key,}): super(key: key);
  
  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 18),
      child: Container(
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
              topRight: Radius.circular(68.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: FitnessAppTheme.grey.withOpacity(0.2),
                offset: Offset(1.1, 1.1),
                blurRadius: 10.0),
          ],
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 4),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                height: 48,
                                width: 2,
                                decoration: BoxDecoration(
                                  color: HexColor('#87A0E5')
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(4.0)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, bottom: 2),
                                      child: Text(
                                        'Total Appointments',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          letterSpacing: -0.1,
                                          color: FitnessAppTheme.grey
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(
                                                  left: 4, bottom: 3),
                                          child: Text(
                                            'test',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme
                                                      .fontName,
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 16,
                                              color: FitnessAppTheme
                                                  .darkerText,
                                            ),
                                          ),
                                        ),                                                
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: 48,
                                width: 2,
                                decoration: BoxDecoration(
                                  color: HexColor('#F56E98')
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(4.0)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, bottom: 2),
                                      child: Text(
                                        'Completed',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          letterSpacing: -0.1,
                                          color: FitnessAppTheme.grey
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(
                                                  left: 4, bottom: 3),
                                          child: Text(
                                            'test',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme
                                                      .fontName,
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 16,
                                              color: FitnessAppTheme
                                                  .darkerText,
                                            ),
                                          ),
                                        ),                                                
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: FitnessAppTheme.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100.0),
                                ),
                                border: Border.all(
                                    width: 4,
                                    color: FitnessAppTheme
                                        .nearlyDarkBlue
                                        .withOpacity(0.2)),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily:
                                          FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 24,
                                      letterSpacing: 0.0,
                                      color: FitnessAppTheme
                                          .nearlyDarkBlue,
                                    ),
                                  ),
                                  Text(
                                    'Left',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily:
                                          FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.0,
                                      color: FitnessAppTheme.grey
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),                        
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
            ),                    
          ],
        ),
      )
    );
  }
}