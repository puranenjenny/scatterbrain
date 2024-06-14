import 'package:flutter/material.dart';
import 'package:scatter_brain/constants/colors.dart';
import 'package:scatter_brain/main.dart';
import 'package:scatter_brain/notifications/shared_helper.dart';
import 'package:scatter_brain/notifications/notification_helper.dart';

class InfoSivu extends StatefulWidget {
  @override
  _InfoSivuState createState() => _InfoSivuState();
}

class _InfoSivuState extends State<InfoSivu> {
  String selectedMorningTime = '10:00'; // alustetaan muuttujat
  String selectedEveningTime = '22:00';
  String selectedFrequency = '10';
  String dailyResetTime = '05:00';
  bool notificationsEnabled = true; // ilmoitukset päällä

  @override
  void initState() {
    super.initState();
    _loadSelections();
  }

  void _loadSelections() async {
    selectedMorningTime = await SharedPreferencesHelper.getString(
        'selectedMorningTime',
        defaultValue: '10:00');
    selectedEveningTime = await SharedPreferencesHelper.getString(
        'selectedEveningTime',
        defaultValue: '22:00');
    selectedFrequency = await SharedPreferencesHelper.getString(
        'selectedFrequency',
        defaultValue: '10');
    dailyResetTime = await SharedPreferencesHelper.getString('dailyResetTime',
        defaultValue: '05:00');
    notificationsEnabled = await SharedPreferencesHelper.getBool(
        'notificationsEnabled',
        defaultValue: true);

    setState(() {
      selectedMorningTime = selectedMorningTime;
      selectedEveningTime = selectedEveningTime;
      selectedFrequency = selectedFrequency;
      dailyResetTime = dailyResetTime;
      notificationsEnabled = notificationsEnabled;
    });
  }

  List<String> generateTimeOptions() {
    // luopdaan aamu ja iltapäivä notifikaatioiden aika vaihtoehdot listaan puolen tunnin välein
    List<String> times = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        String timeString =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        times.add(timeString);
      }
    }
    return times;
  }

  List<String> generateFrequencyOptions() { //luodaan notificaatioiden tiheys lista 1-60min
    List<String> frequencyOptions = ['1', '2', '3', '4'];
    for (int i = 1; i <= 12; i++) {
      frequencyOptions.add('${i * 5}');
    }
    return frequencyOptions;
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
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 25),
            child: Text('Info',
                style: TextStyle(
                    color: Sininen, fontSize: 40, fontFamily: 'GochiHand')),
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
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 0, bottom: 20),
                child: Column(
                  children: [
                    Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 20),
                          child: Text(
                              'This app is designed for all of us scatterbrains to stay on top of our morning and evening routines, as well as everyday errands. ',
                              style: TextStyle(
                                  color: Sininen,
                                  fontSize: 20,
                                  fontFamily: 'FiraCode')),
                        )),
                    ExpansionTile(
                      // taskien lisäys-ohjeet
                      title: Text('Adding tasks',
                          style: TextStyle(
                              color: Turkoosi,
                              fontSize: 20,
                              fontFamily: 'FiraCode')),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, top: 8.0, bottom: 20),
                          child: Text(
                            'You can add new tasks to your To-do list and Daily tasks by tapping the + icon in the To-do tab.',
                            style: TextStyle(
                                color: Sininen,
                                fontSize: 18,
                                fontFamily: 'FiraCode'),
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      // taskien poisto-ohjeet
                      title: Text('Removing tasks',
                          style: TextStyle(
                              color: Turkoosi,
                              fontSize: 20,
                              fontFamily: 'FiraCode')),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, top: 0, bottom: 20),
                          child: Text(
                            'In the to-do tab, you can remove all selected tasks by tapping the trash can icon or one by one by swiping the task from left to right. If you want to remove a Daily task, swipe from right to left and confirm.',
                            style: TextStyle(
                                color: Sininen,
                                fontSize: 18,
                                fontFamily: 'FiraCode'),
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      // aamu notifikaatioiden dropdown valikko
                      title: Text('Notification settings',
                          style: TextStyle(
                              color: Turkoosi,
                              fontSize: 20,
                              fontFamily: 'FiraCode')),
                      children: <Widget>[
                        Text(
                            'You can set reminders and the frequency for your daily tasks here. The notifications stops when you complete all your morning or evening tasks and starts again the next day.',
                            style: TextStyle(
                                color: Sininen,
                                fontSize: 20,
                                fontFamily: 'FiraCode')),
                        SizedBox(height: 20),
                        Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor:
                                Tausta, // taustaväri dropdown valikolle
                          ),
                          child: DropdownButtonFormField<String>(
                            value: selectedMorningTime,
                            onChanged: (newValue) async {
                              if (newValue != null) {
                                setState(() {
                                  selectedMorningTime = newValue;
                                });
                                await SharedPreferencesHelper.setString(
                                    'selectedMorningTime', newValue);
                                NotificationApi.scheduleMorningNotifications();
                                print(
                                    "Morning notifications set at $selectedMorningTime");
                              }
                            },
                            items: timeOptions
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                      color: Sininen,
                                      fontSize: 18,
                                      fontFamily: 'FiraCode'),
                                ),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: "Morning Tasks Start Time",
                              labelStyle: TextStyle(
                                  color: Turkoosi,
                                  fontSize: 20,
                                  fontFamily: 'FiraCode'),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor:
                                Tausta, // taustaväri dropdown valikolle
                          ),
                          child: DropdownButtonFormField<String>(
                            // illan notifikatioiden dropdown
                            value: selectedEveningTime,
                            onChanged: (newValue) async {
                              if (newValue != null) {
                                setState(() {
                                  selectedEveningTime = newValue;
                                });
                                await SharedPreferencesHelper.setString(
                                    'selectedEveningTime', newValue);
                                NotificationApi.scheduleEveningNotifications();
                                print(
                                    "Evening notifications set at $selectedEveningTime");
                              }
                            },
                            items: timeOptions
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                      color: Sininen,
                                      fontSize: 18,
                                      fontFamily: 'FiraCode'),
                                ),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: "Evening Tasks Start Time",
                              labelStyle: TextStyle(
                                  color: Turkoosi,
                                  fontSize: 20,
                                  fontFamily: 'FiraCode'),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor:
                                Tausta, // taustaväri dropdown valikolle
                          ),
                          child: DropdownButtonFormField<String>(
                            // notificatioiden tiheys dropdown
                            value: selectedFrequency,
                            onChanged: (newValue) async {
                              if (newValue != null) {
                                setState(() {
                                  selectedFrequency = newValue;
                                });
                                await SharedPreferencesHelper.setString(
                                    'selectedFrequency', newValue);
                                NotificationApi.scheduleEveningNotifications();
                                NotificationApi.scheduleMorningNotifications();
                                print(
                                    "Notification frequency set at $selectedFrequency");
                              }
                            },
                            items: frequencyOptions
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value + ' minutes',
                                  style: TextStyle(
                                      color: Sininen,
                                      fontSize: 18,
                                      fontFamily: 'FiraCode'),
                                ),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: "Notification Frequency",
                              labelStyle: TextStyle(
                                  color: Turkoosi,
                                  fontSize: 20,
                                  fontFamily: 'FiraCode'),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Here you can toggle notifications on and off. If you turn them off, you will not receive any notifications for your daily tasks. You can turn them back on at any time.',
                          style: TextStyle(
                              color: Sininen,
                              fontSize: 18,
                              fontFamily: 'FiraCode'),
                        ),
                        SizedBox(height: 10),
                        Row( //notificationit on/off
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('OFF',
                                style: TextStyle(
                                    color: Sininen,
                                    fontSize: 20,
                                    fontFamily: 'FiraCode')),
                            Switch(
                              value: notificationsEnabled,
                              onChanged: (newValue) async {
                                setState(() {
                                  notificationsEnabled = newValue;
                                });
                                await SharedPreferencesHelper.setBool(
                                    'notificationsEnabled', newValue);
                              },
                              activeColor: Turkoosi,
                            ),
                            Text('ON',
                                style: TextStyle(
                                    color: Sininen,
                                    fontSize: 20,
                                    fontFamily: 'FiraCode')),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                    ExpansionTile(
                      // daily resetti
                      title: Text('Daily reset',
                          style: TextStyle(
                              color: Turkoosi,
                              fontSize: 20,
                              fontFamily: 'FiraCode')),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, top: 10, bottom: 20),
                          child: Column(
                            children: [
                              Text(
                                'The reset time clears your Daily tasks, preparing you for a fresh start each day.',
                                style: TextStyle(
                                    color: Sininen,
                                    fontSize: 18,
                                    fontFamily: 'FiraCode'),
                              ),
                              SizedBox(height: 30),
                              Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor:
                                      Tausta, // taustaväri dropdown valikolle
                                ),
                                child: DropdownButtonFormField<String>(
                                  // päivittäisen resetoinnin aika
                                  value: dailyResetTime,
                                  onChanged: (newValue) async {
                                    if (newValue != null) {
                                      setState(() {
                                        dailyResetTime = newValue;
                                      });
                                      await SharedPreferencesHelper.setString(
                                          'dailyResetTime', newValue);
                                      scheduleDailyReset();
                                      print(
                                          "Scheduling daily reset at: $dailyResetTime");
                                    }
                                  },
                                  items: timeOptions
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                            color: Sininen,
                                            fontSize: 18,
                                            fontFamily: 'FiraCode'),
                                      ),
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    labelText: "Daily Reset Time",
                                    labelStyle: TextStyle(
                                        color: Turkoosi,
                                        fontSize: 20,
                                        fontFamily: 'FiraCode'),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Center(
                        child: Text(
                            'We hope Scatterbrain helps you keep track of your daily tasks and makes your life a little bit easier. ✨',
                            style: TextStyle(
                                color: Sininen,
                                fontSize: 20,
                                fontFamily: 'FiraCode'))),
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
