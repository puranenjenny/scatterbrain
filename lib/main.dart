import 'package:flutter/material.dart'; // flutterin materiaalikirjasto
import 'daily.dart';
import 'todo.dart';
import 'info.dart';
import 'constants/colors.dart'; // värit

void main() { // pääohjelma
  runApp(const MyApp()); // käynnistetään myapp sovellus
}

class MyApp extends StatelessWidget { // myapp sovellus
  const MyApp({super.key}); // konstruktori

  @override // ylikirjoitetaan build metodi
  Widget build(BuildContext context) { // rakennetaan sovellus
    return MaterialApp( // palautetaan sovellus näytettäväksi
      debugShowCheckedModeBanner: false, // poistetaan debug banneri
      title: 'Scatterbrain', // sovelluksen nimi
      theme: ThemeData( // teema
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 26, 193, 199)), // väri
        useMaterial3: true, // käytetään materiaaliteemaa
      ),
      home: const MyHomePage(title: 'Scatterbrain HomeSivu'), // kotisivu
    );
  }
}

class MyHomePage extends StatefulWidget { // kotisivu luokka
  const MyHomePage({super.key, required this.title}); // konstruktori
  final String title; 

  @override
  State<MyHomePage> createState() => MyHomePageState(); // palautetaan kotisivun tila
}

class MyHomePageState extends State<MyHomePage> { // kotisivun tila luokka
  int valittuIndexi = 0; // alavalikon valinta

  void _onItemTapped(int index) { // kun klikataan alavalikkoa
    setState(() { //asetetaan uusi state
      valittuIndexi = index; // asetetaan valittu sivu
    });
  }

  @override
  Widget build(BuildContext context) { // rakennetaan kotisivu
    final List<Widget> Sivut = [ // sivut
      DailySivu(), // päivittäiset tehtävät
      ToDoSivu(), // todo lista
      InfoSivu(), // kalenteri
    ];

    return Scaffold( // palautetaan sivuston runko
      appBar: AppBar( // yläpalkki
        toolbarHeight: 110, // korkeus kovakoodattu jotta logo on sopiva
        backgroundColor:TummaTausta, // yläpalkin taustaväri
        title: Center(child: Image.asset('images/logo.png')), // logo keskellä
      ),
      body: Center(
        child: Sivut.elementAt(valittuIndexi), // näyttää kyseisen sivun
      ),
      bottomNavigationBar: BottomNavigationBar(
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_system_daydream_outlined), // Käytä omaa ikonia
        label: 'Daily',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.checklist_rounded), // Käytä toista omaa ikonia
        label: 'To-Do',     
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.info_outline_rounded), // Kolmas oma ikoni
        label: 'Info',
      ),
    ],
    currentIndex: valittuIndexi,
    onTap: _onItemTapped, // kun klikataan alavalikkoa
        backgroundColor: TummaTausta, //alavalikon taustaväri
        selectedItemColor: Turkoosi, // valitun kohteen väri
        selectedIconTheme: IconThemeData(size: 40),
        unselectedItemColor: Sininen, // valitsemattoman kohteen väri
        unselectedIconTheme: IconThemeData(size: 30),
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'FireCode',
          fontSize: 20,
          ),  // valitun labelin tyyli
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontFamily: 'FireCode',
          fontSize: 20,), // valitsemattoman labelin tyyli
      ),
      backgroundColor:  Tausta // scaffoldin taustaväri
    );
  }
}

