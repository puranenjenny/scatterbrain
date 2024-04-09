import 'package:flutter/material.dart';
import 'package:scatter_brain/constants/colors.dart';
import 'package:scatter_brain/notifications/shared_helper.dart';

class InfoSivu extends StatefulWidget {
  @override
  _InfoSivuState createState() => _InfoSivuState();
}

class _InfoSivuState extends State<InfoSivu> {
  // Initialize the selected times as the first option in the dropdown
  String selectedMorningTime = '10:00';
  String selectedEveningTime = '22:00';
  String selectedFrequency = '10';
  String dailyResetTime = '05:00';

  bool notificationsEnabled = true; // ilmoitukset päällä

  // luopdaan aamu ja iltapäivä notifikaatioiden aika vaihtoehdot listaan puolen tunnin välein
  List<String> generateTimeOptions() {
    List<String> times = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        String timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        times.add(timeString);
      }
    }
    return times;
  }

  // luodaan notifikaatioiden tiheys vaihtoehdot listaan
  List<String> generateFrequencyOptions() {
    return List.generate(6, (index) => '${(index + 1) * 10}');
  }

  @override
  Widget build(BuildContext context) {
    List<String> timeOptions = generateTimeOptions();
    List<String> frequencyOptions = generateFrequencyOptions();

    return Scaffold(
      backgroundColor: Tausta,
      appBar: AppBar(
        backgroundColor: Tausta,
        toolbarHeight: 98,
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 25),
          child: Text('Info', style: TextStyle(color:Sininen, fontSize: 50, fontFamily: 'GochiHand')),
        )),
       body: Stack(
        children: [
          Opacity(
            opacity: 0.48,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/tausta_info.png"), // taustakuva
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 20),
                child: Column(
                  children: [
                    Center(child: Text('This app is designed for all of us scatterbrains to stay on top of our morning and evening routines, as well as everyday errands. ', style: TextStyle(color: Sininen, fontSize: 20, fontFamily: 'FiraCode'))),
                    SizedBox(height: 20),

                    ExpansionTile( // taskien lisäys-ohjeet
                      title: Text('Adding tasks', style: TextStyle(color: Turkoosi, fontSize: 20, fontFamily: 'FiraCode')),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 20),
                          child: Text(
                            'You can add new tasks to your To-do list and Daily tasks by tapping the + icon in the To-do tab.',
                            style: TextStyle(color: Sininen, fontSize: 18, fontFamily: 'FiraCode'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    ExpansionTile( // taskien poisto-ohjeet
                      title: Text('Removing tasks', style: TextStyle(color: Turkoosi, fontSize: 20, fontFamily: 'FiraCode')),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0, bottom: 20),
                          child: Text(
                            'In the to-do tab, you can remove all selected tasks by tapping the trash can icon or one by one by swiping the task from left to right. If you want to remove a Daily task, swipe from right to left and confirm.',
                            style: TextStyle(color: Sininen, fontSize: 18, fontFamily: 'FiraCode'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
            
                    ExpansionTile(// aamu notifikaatioiden dropdown valikko
                      title: Text('Setting reminders', style: TextStyle(color: Turkoosi, fontSize: 20, fontFamily: 'FiraCode')),
                      children: <Widget>[
                        Text('You can set reminders and the frequency for your daily tasks here. The notifications stops when you complete all your morning or evening tasks and starts again the next day.', style: TextStyle(color: Sininen, fontSize: 20, fontFamily: 'FiraCode')),
                        SizedBox(height: 20),

                        Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Tausta, // taustaväri dropdown valikolle
                          ), child:
                        DropdownButtonFormField<String>(
                          value: selectedMorningTime,
                          onChanged: (newValue) async {
                            setState(() {
                              selectedMorningTime = newValue!;
                            });
                            await SharedPreferencesHelper.setString('selectedMorningTime', selectedMorningTime);
                          },
                          items: timeOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(color: Sininen, fontSize: 20, fontFamily: 'FiraCode'),
                            ),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: "Morning Tasks Start Time",
                            labelStyle: TextStyle(color: Turkoosi, fontSize: 20, fontFamily: 'FiraCode'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        ),
                    SizedBox(height: 20),
                    
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Tausta, // taustaväri dropdown valikolle
                      ), child:
                    DropdownButtonFormField<String>( // illan notifikatioiden dropdown
                      value: selectedEveningTime,
                      onChanged: (newValue) async {
                        setState(() {
                          selectedEveningTime = newValue!;
                        });
                        await SharedPreferencesHelper.setString('selectedEveningTime', selectedEveningTime);
                      },
                      items: timeOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: Sininen, fontSize: 20, fontFamily: 'FiraCode'),),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: "Evening Tasks Start Time",
                        labelStyle: TextStyle(color: Turkoosi, fontSize: 20, fontFamily: 'FiraCode'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    ),

                    SizedBox(height: 20),
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Tausta, // taustaväri dropdown valikolle
                      ), child:
                    DropdownButtonFormField<String>(// notificatioiden tiheys dropdown
                      value: selectedFrequency,
                      onChanged: (newValue) async {
                        setState(() {
                          selectedFrequency = newValue!;
                        });
                        await SharedPreferencesHelper.setString('selectedFrequency', selectedFrequency);
                      },
                      items: frequencyOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value + ' minutes', style: TextStyle(color: Sininen, fontSize: 20, fontFamily: 'FiraCode'),),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: "Notification Frequency",
                        labelStyle: TextStyle(color: Turkoosi, fontSize: 20, fontFamily: 'FiraCode'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    ),
                    ],
                    ),
                    SizedBox(height: 20),
                    
                    ExpansionTile( // notifikaatioiden päälle/pois
                      title: Text('Notifications and daily reset', style: TextStyle(color: Turkoosi, fontSize: 20, fontFamily: 'FiraCode')),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0, bottom: 0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('OFF', style: TextStyle(color: Sininen, fontSize: 20, fontFamily: 'FiraCode')),
                                  Switch(
                                    value: notificationsEnabled,
                                    onChanged: (value) async {
                                      setState(() {
                                        notificationsEnabled = value;
                                      });
                                      await SharedPreferencesHelper.setBool('notificationsEnabled', notificationsEnabled);
                                    },
                                    activeColor: Turkoosi,
                                  ),
                                  Text('ON', style: TextStyle(color: Sininen, fontSize: 20, fontFamily: 'FiraCode')),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Here you can toggle notifications on and off. If you turn them off, you will not receive any notifications for your daily tasks. You can turn them back on at any time.',
                                style: TextStyle(color: Sininen, fontSize: 18, fontFamily: 'FiraCode'),
                                
                              ),
                              
                              SizedBox(height: 20),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Tausta, // taustaväri dropdown valikolle
                                  ), child:
                              DropdownButtonFormField<String>( // päivittäisen resetoinnin aika
                                value: dailyResetTime,
                                onChanged: (newValue) async {
                                  setState(() {
                                    dailyResetTime = newValue!;
                                  });
                                 await SharedPreferencesHelper.setString('dailyResetTime', dailyResetTime);
                                },
                                items: timeOptions.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: TextStyle(color: Sininen, fontSize: 20, fontFamily: 'FiraCode'),),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  labelText: "Daily Reset Time",
                                  labelStyle: TextStyle(color: Turkoosi, fontSize: 20, fontFamily: 'FiraCode'),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                                                  ),
                              SizedBox(height: 20),
                              Text(
                                'The reset time clears your Daily tasks, preparing you for a fresh start each day.',
                                style: TextStyle(color: Sininen, fontSize: 18, fontFamily: 'FiraCode'),
                              ),
                              SizedBox(height: 20),
                            ],

                          
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(child: Text('We hope Scatterbrain helps you keep track of your daily tasks and makes your life a little bit easier. ✨', style: TextStyle(color: Sininen, fontSize: 20, fontFamily: 'FiraCode'))),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}