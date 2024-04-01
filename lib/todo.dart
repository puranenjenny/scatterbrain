import 'package:flutter/material.dart';

class ToDoSivu extends StatefulWidget {
  @override
  _ToDoSivuState createState() => _ToDoSivuState();
}

class _ToDoSivuState extends State<ToDoSivu> { // todo sivu luokka
  final List<String> _todos = []; // todo lista

  void _addTodoItem(String task) { //lisätään tehtävä metodi johon syötetään tehtävä
    if (task.isNotEmpty) { // jos tehtävä ei ole tyhjä
      setState(() { // asetetaan uusi state
        _todos.add(task); // lisätään tehtävä
      });
    }
  }

  void _showAddTodoDialog() { // lisää tehtävä ikkuna metodi joka avaa ikkunan ja kysyy tehtävää
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _textFieldController = TextEditingController(); // tekstikentän controller

        return AlertDialog( // palautetaan alertdialog
          title: Text('Add a task', style: TextStyle(color: Color(0xFFA3DAFF), fontFamily: 'GochiHand', fontSize: 30)),
          backgroundColor: Color(0xFF1F1F1F),
          content: TextField(
            style: TextStyle(color: Color(0xFFA3DAFF), fontFamily: 'FiraCode'),
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Write a task here..." ,hintStyle: TextStyle(color: Color(0xFFA3DAFF), 
            fontFamily: 'FiraCode'), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFA3DAFF))), 
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFA3DAFF)))),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add', style: TextStyle(color: Color(0xFFA3DAFF), fontFamily: 'FiraCode')),
              onPressed: () {
                _addTodoItem(_textFieldController.text);
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
      backgroundColor: Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: Color(0xFF1F1F1F),
        toolbarHeight: 90,
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 25),
          child: Text('Todo List', style: TextStyle(color: Color(0xFFA3DAFF), fontSize: 50, fontFamily: 'GochiHand')),
        ),
        actions: <Widget>[ // Lisätään actions tähän
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
          child: IconButton(
            icon: Image.asset('images/btn_add.png'), // Käytä omaa nappikuvaketta
                onPressed: _showAddTodoDialog,
          ),
        ),
      ],
      ),
      body: Container(
        decoration: BoxDecoration( 
        image: DecorationImage(
          image: AssetImage("images/tausta_todo.png"), // taustakuva
          fit: BoxFit.cover, // täyttää koko ruudun
        ),
      ),
        child: Stack(
        children: [
          ListView.builder(
            itemCount: _todos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 30, right: 20),
                child: ListTile(
                  title: Text(_todos[index], style: TextStyle(color: Color(0xFFA3DAFF), fontFamily: 'FiraCode', fontSize: 20),),
                ),
              );
            },
          ),
        ],
            ),
      ),
    );
  }
}
