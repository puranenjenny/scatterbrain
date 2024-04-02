import 'package:flutter/material.dart';
import 'package:scatter_brain/database/database_helper.dart';
import 'package:scatter_brain/database/task_model.dart'; // Säädä import-polku projektisi rakenteen mukaan
import 'package:scatter_brain/constants/colors.dart'; // Varmista, että tämä polku on oikein

class ToDoSivu extends StatefulWidget {
  const ToDoSivu({Key? key}) : super(key: key);

  @override
  _ToDoSivuState createState() => _ToDoSivuState();
}

class _ToDoSivuState extends State<ToDoSivu> {
  List<Task> _todos = [];
  final TextEditingController _textFieldController = TextEditingController();

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
          title: Text('Add a task', style: TextStyle(color: Sininen, fontFamily: 'GochiHand', fontSize: 30)),
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
/*                 IconButton(
                icon: Icon(Icons.add, color: Sininen), // Voit vaihtaa ikonin tarpeesi mukaan
                onPressed: () {
                  _showAddtoDailyDialog();
                },), */
                TextButton(
                  child: Text('Save', style: TextStyle(color: Sininen, fontFamily: 'FiraCode')),
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

  void _showDeleteTodoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete selected', style: TextStyle(color: Sininen, fontFamily: 'GochiHand', fontSize: 30)),
          backgroundColor: Tausta,
          actions: <Widget>[
            TextButton(
              child: Text('Click here to delete', style: TextStyle(color: Sininen, fontFamily: 'FiraCode')),
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
        toolbarHeight: 90,
        title: Text('Todo List', style: TextStyle(color: Sininen, fontSize: 50, fontFamily: 'GochiHand')),
        actions: <Widget>[
          IconButton(
            icon: Image.asset('images/btn_add.png', width: 44, height: 44), //lisää nappi
            onPressed: _showAddTodoDialog,
          ),
          IconButton(
            icon: Image.asset('images/trash2.png', width: 44, height: 44), // poista nappi
            onPressed: _showDeleteTodoDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/tausta_todo.png"), // Taustakuva
            fit: BoxFit.cover,
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
    );
  }
}
