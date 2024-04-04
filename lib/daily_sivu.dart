import 'package:flutter/material.dart';
import 'package:scatter_brain/api/notification_api.dart';
import 'package:intl/intl.dart';
import 'package:scatter_brain/constants/colors.dart';
import 'package:scatter_brain/database/daily_model.dart';
import 'package:scatter_brain/database/database_helper.dart'; 
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailySivu extends StatefulWidget {
  @override
  State<DailySivu> createState() => _DailySivuState();
}

class _DailySivuState extends State<DailySivu> {
  List<Daily> _morningDailys = [];
  List<Daily> _eveningDailys = [];


  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _loadDailys();
  }

  void _loadDailys() async {
    final dailys = await DatabaseHelper.getDailyTasks();
    if (dailys != null) {
      setState(() {
          _morningDailys = dailys.where((daily) => daily.timeOfDay == 'Morning').toList();
        _eveningDailys = dailys.where((daily) => daily.timeOfDay == 'Evening').toList();
      });
    }
  }

  Widget _buildTaskList(List<Daily> tasks, String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(title, style: TextStyle(fontSize: 24, color: Sininen, fontFamily: 'GochiHand')),
      ),
      for (var task in tasks)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CheckboxListTile(
            title: Text(task.title, style: TextStyle(color: Turkoosi, fontFamily: 'FiraCode', fontSize: 20)),
            value: task.done,
            onChanged: (bool? newValue) {
              if (newValue != null) {
                final updatedTask = Daily(title: task.title, done: newValue, id: task.id, timeOfDay: task.timeOfDay);
                DatabaseHelper.updateDailyTask(updatedTask);
                _loadDailys();
              }
            },
          ),
        ),
    ],
  );
  }

  String _getBackgroundImage() {
    bool allMorningDone = _morningDailys.isNotEmpty && _morningDailys.every((task) => task.done);
    bool allEveningDone = _eveningDailys.isNotEmpty && _eveningDailys.every((task) => task.done);

    if (allMorningDone && !allEveningDone) {
      return "images/tausta_aamu.png";
    } else if (allMorningDone && allEveningDone) {
      return "images/tausta_ilta.png";
    } else {
      return "images/tausta_alku.png";
    }
  }


 @override
Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

    return Scaffold(
      backgroundColor: Tausta,
      appBar: AppBar(
        backgroundColor: Tausta,
        toolbarHeight: 108,
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                 mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Daily Tasks', style: TextStyle(color: Sininen, fontSize: 50, fontFamily: 'GochiHand')),
                  SizedBox(width: 30), 
                  Image.asset('images/daily.png', width: 50, height: 50,)
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(formattedDate, style: TextStyle(color: PilkutBeessi, fontSize: 15, fontFamily: 'FiraCode')),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_getBackgroundImage()), // haetaan taustakuva
                fit: BoxFit.cover, // täyttää koko alueen
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, top: 0, bottom: 14),
              child: Column(
                children: [
                  _buildTaskList(_morningDailys, "Morning Tasks"),
                  _buildTaskList(_eveningDailys, "Evening Tasks"),
                  _buildButton(
                    title: 'Show Notification',
                    icon: Icon(Icons.notifications), // Use an icon widget directly
                    onPressed: () async {
                      await NotificationApi.showNotification(
                        title: 'Reminder',
                        body: 'You have unfinished tasks!',
                        payload: 'payload', // payload tarkoittaa tietoa joka voidaan lähettää notifikaation mukana, optional
                      );
                    },
                  ),
/*                   _buildButton(
                    title: 'Show Notification in 5 seconds (Scheduled)',
                    icon: Icon(Icons.notifications), // Use an icon widget directly
                    onPressed: () async {
                      await NotificationApi.show5SecondsNotification(
                        title: 'Reminder',
                        body: 'You have unfinished tasks!',
                        payload: 'payload', // payload tarkoittaa tietoa joka voidaan lähettää notifikaation mukana, optional
                        scheduledDate: scheduledDate,
                      );
                    },
                  ), */
                  _buildButton(
                    title: 'Show Notification in 5 seconds (Scheduled)',
                    icon: Icon(Icons.notifications),
                    onPressed: () async {
                      final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
                      await NotificationApi.show5SecondsNotification(
                        id: 1, // Uniikki ID jokaiselle ilmoitukselle
                        title: 'Reminder',
                        body: 'You have unfinished tasks!',
                        payload: 'payload',
                        scheduledDate: scheduledDate, // Ajastettu aika
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
}

Widget _buildButton({required String title, required Widget icon, required VoidCallback onPressed}) {
  return ElevatedButton.icon(
    icon: icon,
    label: Text(title),
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Sininen,
      foregroundColor: TummaTausta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
      ),
    ),
  );
}


}