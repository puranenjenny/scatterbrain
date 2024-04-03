import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scatter_brain/constants/colors.dart';
import 'package:scatter_brain/database/daily_model.dart';
import 'package:scatter_brain/database/database_helper.dart'; 

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

 @override
Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

    return Scaffold(
      backgroundColor: Tausta,
      appBar: AppBar(
        backgroundColor: Tausta,
        toolbarHeight: 98,
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
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
                padding: const EdgeInsets.only(left: 20),
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
                image: AssetImage("images/tausta_aamu.png"), // Taustakuva
                fit: BoxFit.cover, // Muuta BoxFit.coveriksi, jotta se peittää koko alueen
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTaskList(_morningDailys, "Morning Tasks"),
                  _buildTaskList(_eveningDailys, "Evening Tasks"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
}
}