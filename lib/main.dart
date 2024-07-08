import 'dart:async';
import 'package:flutter/material.dart'; // flutterin materiaalikirjasto
import 'package:permission_handler/permission_handler.dart';
import 'package:scatter_brain/notifications/notification_helper.dart';
import 'package:scatter_brain/database/database_helper.dart';
import 'package:scatter_brain/notifications/shared_helper.dart';
import 'daily_sivu.dart'; //sivut
import 'todo_sivu.dart';
import 'info_sivu.dart';
import 'constants/colors.dart'; // värit
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // varmistetaan, että widgetit on alustettu
  await AndroidAlarmManager.initialize(); // alustetaan android alarm manager
  NotificationApi.init(); // alustetaan ilmoitukset

  Timer.periodic(Duration(minutes: 1), (Timer t) => printCurrentTime());  // timeri testaukseen

  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  await Permission.notification.isDenied.then((value) // jos notificationeja ei ole sallittu
  {
    if (value) {
      Permission.notification.request(); // pyydetään notification oikeudet uudemmissa android malleissa
    }
  });

  await SharedPreferencesHelper.initialize(); // alustetaan shared preferences

  tz.initializeTimeZones(); //alustetaan timezone
  var helsinki = tz.getLocation('Europe/Helsinki'); //ja asetetaan se helsinkiin
  tz.setLocalLocation(helsinki);

  bool notificationsEnabled = SharedPreferencesHelper.getBool('notificationsEnabled'); // varmistetaan että ilmoitukset käynnistyvät käyttäjän määrittelemien asetusten mukaisesti
  if (notificationsEnabled) { //jos notificaatiot on päällä, kutsutaan aamu ja ilta notificationeja
    NotificationApi.scheduleMorningNotifications();
    NotificationApi.scheduleEveningNotifications();
    print("notifikaatiot on päällä: $notificationsEnabled" );
  }

  scheduleDailyReset(); // kutsutaan päivittäinen resetointi funktiota
  runApp(MyApp()); // käynnistetään sovellus

}


//timeri debuggailuun
void printCurrentTime() {
  print("Current Helsinki time: ${tz.TZDateTime.now(tz.getLocation('Europe/Helsinki'))}");

}

// tehtävien resetointi

@pragma('vm:entry-point') // hattu joka sallii funktion suoritettavaksi myös taustalla
void resetDailyTasks() async { // resetoi päivittäiset tehtävät
  await DatabaseHelper.resetAllDailysToNotDone(); // kutsutaan DatabaseHelper:in funktiota jotta saadaan kaikki daily tehtävät done: false
  await NotificationApi.cancelMorningNotifications();
  await NotificationApi.cancelEveningNotifications();
  await SharedPreferencesHelper.setBool('morningMessageShown', false);
  await SharedPreferencesHelper.setBool('eveningMessageShown', false);

  bool notificationsEnabled = await SharedPreferencesHelper.getBool('notificationsEnabled');// asetetaan uudet notifikaatiot peruutuksen jälkeen
  if (notificationsEnabled) {
    NotificationApi.scheduleMorningNotifications();
    NotificationApi.scheduleEveningNotifications();
    print("Uudet notifikaatiot asetettu resetin jälkeen: $notificationsEnabled");
  }
}

@pragma('vm:entry-point')
void scheduleDailyReset() async { //daily resetin ajoitus
  final int alarmId = 5; // uniikki id

  String dailyResetTime = await SharedPreferencesHelper.getString('dailyResetTime');
  List<String> timeParts = dailyResetTime.split(':');
  try {
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    final tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation('Europe/Helsinki'));
    final tz.TZDateTime firstTime = tz.TZDateTime(now.location, now.year, now.month, now.day, hour, minute);
    final tz.TZDateTime scheduleTime = firstTime.isBefore(now) ? firstTime.add(const Duration(days: 1)) : firstTime;

    print("Scheduling daily reset at: $scheduleTime");

    await AndroidAlarmManager.periodic(
        const Duration(days: 1), // kerran päivässä
        alarmId, // uniikki id
        resetDailyTasks, // kursuu resettiä
        startAt: scheduleTime,
        exact: true,
        wakeup: true
    );
  } catch (e) {
    print('Error setting daily reset time: $e');
  }
}

// notificationit

Future<void> _showNotification() async {
  var androidDetails = AndroidNotificationDetails('channelId', 'channelName');
  var generalNotificationDetails = NotificationDetails(android: androidDetails);
  await flutterLocalNotificationsPlugin.show(3, 'Hey there!', 'You have unfinished tasks!', generalNotificationDetails);
}

 void checkAndNotifyTasks() async {  // tarkistetaan että tehtävät on tehny, palauttaa 'true'
  bool areTasksDone = await DatabaseHelper.areAllTasksDone();
  if (!areTasksDone) {
    _showNotification();
  }
}


// appi

class MyApp extends StatelessWidget { // myapp sovellus
  const MyApp({super.key}); // konstruktori

  @override // ylikirjoitetaan build metodi
  Widget build(BuildContext context) { // rakennetaan sovellus
    return MaterialApp( // palautetaan sovellus näytettäväksi
      debugShowCheckedModeBanner: false, // poistetaan debug banneri
      title: 'Scatterbrain', // sovelluksen nimi
      theme: ThemeData( // teema
        colorScheme: ColorScheme.fromSeed(seedColor: Turkoosi), // väri
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
        toolbarHeight: 115, // korkeus kovakoodattu jotta logo on sopiva
        backgroundColor:TummaTausta, // yläpalkin taustaväri
        title: Center(child: Image.asset('images/logo.png')), // logo keskellä
      ),
      body: Center( // keskitys
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
        selectedIconTheme: IconThemeData(size: 40), //valitun iconin koko
        unselectedItemColor: Sininen, // valitsemattoman kohteen väri
        unselectedIconTheme: IconThemeData(size: 30), // valitsemattoman iconin koko
        selectedLabelStyle: TextStyle( // valitun labelin tekstisäädöt
          fontWeight: FontWeight.bold, // lihavoitu
          fontFamily: 'FireCode',
          fontSize: 20,
          ), 
        unselectedLabelStyle: TextStyle( // valitsemattoman labelin tekstisäädöt
          fontWeight: FontWeight.normal,
          fontFamily: 'FireCode',
          fontSize: 20,
          ),
      ),
      backgroundColor: Tausta // scaffoldin taustaväri
    );
  }
}

