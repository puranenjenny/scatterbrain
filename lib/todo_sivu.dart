import 'package:flutter/material.dart';
import 'package:scatter_brain/database/daily_model.dart';
import 'package:scatter_brain/database/database_helper.dart';
import 'package:scatter_brain/database/task_model.dart'; 
import 'package:scatter_brain/constants/colors.dart'; 

class ToDoSivu extends StatefulWidget {
  const ToDoSivu({Key? key}) : super(key: key);

  @override
  _ToDoSivuState createState() => _ToDoSivuState();
}

class _ToDoSivuState extends State<ToDoSivu> {
  List<Task> _todos = [];
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _dailyTextFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

void _loadTodos() async {
  final tasks = await DatabaseHelper.getTasks();
  if (tasks != null) {
    // Järjestä tehtävät niin, että tekemättömät (done == false) tulevat ensin
    tasks.sort((a, b) {
      if (a.done == b.done) {
        return 0; // Älä muuta järjestystä, jos molemmat ovat samassa tilassa
      } else if (a.done && !b.done) {
        return 1; // Siirrä tehtyjä tehtäviä listan loppuun
      } else {
        return -1; // Pidä tekemättömät tehtävät listan alussa
      }
    });

    setState(() {
      _todos = tasks;
    });
  }
}

  void _showAddTodoDialog() { // lisää tehtävä dialogi
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ADD A TASK', style: TextStyle(color: Turkoosi, fontFamily: 'GochiHand', fontSize: 30)),
          backgroundColor: Tausta,
          content: TextField(
            style: TextStyle(color: Sininen, fontFamily: 'FiraCode'),
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Write a task here...", hintStyle: TextStyle(color: Sininen, fontFamily: 'FiraCode'), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Sininen)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Sininen))),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // rivin keskitys
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showAddDailyTaskDialog();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Minimoi Row'n leveyden sen sisällön mukaan
                    children: <Widget>[
                      Image.asset('images/daily.png', width: 30, height: 30), // Säädä kuvan kokoa tarpeen mukaan
                      SizedBox(width: 8), // Lisää väliä kuvan ja tekstin välille
                      Text('DAILY', style: TextStyle(color: Sininen, fontFamily: 'FiraCode', fontSize: 18)),
                    ],
                  ),
                ),
                TextButton(
                  child: Text('SAVE', style: TextStyle(color: Sininen, fontFamily: 'FiraCode', fontSize: 18)),
                  onPressed: () {
                    if (_textFieldController.text.isNotEmpty) {
                      final newTask = Task(title: _textFieldController.text, done: false);
                      DatabaseHelper.addTask(newTask);
                      _textFieldController.clear();
                      _loadTodos();
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

String _selectedTimeOfDay = 'Morning';

void _showAddDailyTaskDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('ADD A DAILY TASK', style: TextStyle(color: Pinkki, fontFamily: 'GochiHand', fontSize: 30)),
        backgroundColor: Tausta,
        content: SingleChildScrollView( // Tämä varmistaa, että kaikki mahtuu näkyviin
          child: Column(
            mainAxisSize: MainAxisSize.min, // Säätää koon sisällön mukaan
            children: <Widget>[
              TextField(
                style: TextStyle(color: Sininen, fontFamily: 'FiraCode'),
                controller: _dailyTextFieldController,
                decoration: InputDecoration(hintText: "Write a daily task here...", hintStyle: TextStyle(color: Sininen, fontFamily: 'FiraCode'), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Sininen)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Sininen))),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedTimeOfDay,
                onChanged: (String? newValue) {
                  // Tässä kohdassa setState voi olla tarpeeton, riippuen sovelluksesi rakenteesta
                  _selectedTimeOfDay = newValue!;
                },
                items: <String>['Morning', 'Evening', ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Sininen, fontFamily: 'FiraCode', fontSize: 18)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // rivin keskitys
              children: [
                TextButton(
                  child: Text('CANCEL', style: TextStyle(color: Sininen, fontFamily: 'FiraCode', fontSize: 18)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('SAVE', style: TextStyle(color: Sininen, fontFamily: 'FiraCode', fontSize: 18)),
                  onPressed: () {
                    if (_dailyTextFieldController.text.isNotEmpty) {
                      final newDaily = Daily(title: _dailyTextFieldController.text, done: false, timeOfDay: _selectedTimeOfDay,);
                      DatabaseHelper.addDailyTask(newDaily);
                      _dailyTextFieldController.clear();
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  void _showDeleteTodoDialog() { // poista valitut tehtävät dialogi
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('DELETE SELECTED', style: TextStyle(color: Sininen, fontFamily: 'GochiHand', fontSize: 30)),
          backgroundColor: Tausta,
          actions: <Widget>[
            TextButton(
              child: Text('Click here to delete', style: TextStyle(color: Sininen, fontFamily: 'FiraCode', fontSize: 18)),
              onPressed: () {
                DatabaseHelper.deleteSelectedTasks();
                _loadTodos();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tausta,
      appBar: AppBar(
        backgroundColor: Tausta,
        toolbarHeight: 98,
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 25),
          child: Text('Todo List', style: TextStyle(color: Sininen, fontSize: 50, fontFamily: 'GochiHand')),
        ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset('images/btn_add.png', width: 44, height: 44), //lisää nappi
            onPressed: _showAddTodoDialog,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Image.asset('images/trash2.png', width: 44, height: 44), // poista nappi
              onPressed: _showDeleteTodoDialog,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
        child: Container( // container joka sisältää listan
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/tausta_todo.png"), // taustakuva
              fit: BoxFit.fill, // fill täyttää koko alueen
            ),
          ),
          child: ListView.builder(
            itemCount: _todos.length,
            itemBuilder: (context, index) {
              final task = _todos[index];
              return Dismissible(
                key: Key(task.id.toString()),
                background: Container(color: TummaTausta),
                onDismissed: (direction) {
                  DatabaseHelper.deleteTask(task.id!);
                  _loadTodos();
                },
                child: CheckboxListTile( // checkbox jolla voi säätää onko tehtävä done vai ei
                  title: Text(task.title, style: TextStyle(color: Turkoosi, fontFamily: 'FiraCode', fontSize: 20)),
                  value: task.done,
                  onChanged: (bool? newValue) {
                    if (newValue != null) {
                      final updatedTask = Task(title: task.title, done: newValue, id: task.id);
                      DatabaseHelper.updateTask(updatedTask);
                      _loadTodos();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
