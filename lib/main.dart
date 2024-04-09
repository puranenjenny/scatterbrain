import 'package:flutter/material.dart'; // flutterin materiaalikirjasto
import 'package:permission_handler/permission_handler.dart';
import 'package:scatter_brain/notifications/notification_helper.dart';
import 'package:scatter_brain/database/database_helper.dart';
import 'package:scatter_brain/notifications/shared_helper.dart';
import 'daily_sivu.dart';
import 'todo_sivu.dart';
import 'info_sivu.dart';
import 'constants/colors.dart'; // värit
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // varmistetaan, että widgetit on alustettu
  await AndroidAlarmManager.initialize(); // alustetaan android alarm manager
  NotificationApi.init(); // alustetaan ilmoitukset

  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  await Permission.notification.isDenied.then((value) // jos notificationeja ei ole sallittu
  {
    if (value) {
      Permission.notification.request(); // pyydetään notification oikeudet
    }
  });

  await SharedPreferencesHelper.initialize(); // alustetaan shared preferences
  scheduleDailyReset(); // kutsutaan päivittäinen resetointi funktiota
  runApp(MyApp());
  /* final int dailyResetId = 1;
  await AndroidAlarmManager.periodic(const Duration(minutes: 1), dailyResetId, resetDailyTasks); */
}

// tehtävien resetointi

@pragma('vm:entry-point') // hattu joka pakottaa funktion suoritettavaksi myös taustalla
void resetDailyTasks() async { // resetoi päivittäiset tehtävät
  await DatabaseHelper.resetAllDailysToNotDone(); // kutsutaan DatabaseHelper:in funktiota jotta saadaan kaikki daily tehtävät done: false
}

void scheduleDailyReset() async { // aikataulutetaan päivittäinen resetointi klo 5 aamulla
  final int alarmId = 2; // uniikki ID hälytykselle
  final DateTime now = DateTime.now();
  final DateTime firstTime = DateTime(now.year, now.month, now.day, 5, 0, 0); 
  final DateTime scheduleTime = firstTime.isBefore(now) ? firstTime.add(Duration(minutes: 1)) : firstTime;

  await AndroidAlarmManager.periodic(
    const Duration(minutes: 1),
    alarmId, 
    resetDailyTasks,
    startAt: scheduleTime,
    exact: true,
    wakeup: true,
  );
}

// notificationit

Future<void> _showNotification() async {
  var androidDetails = AndroidNotificationDetails('channelId', 'channelName');
  var generalNotificationDetails = NotificationDetails(android: androidDetails);
  await flutterLocalNotificationsPlugin.show(3, 'Hey there!', 'You have unfinished tasks!', generalNotificationDetails);
}

/* void requestExactAlarmPermission() {
  final AndroidIntent intent = AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
  );
  intent.launch();
} */

/* void scheduleMorningTasks() {
  final morningStart = DateTime.now().add(Duration(days: 1)).subtract(Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute)); // Seuraavan päivän klo 00:00
  final morningEnd = morningStart.add(Duration(hours: 13)); // Seuraavan päivän klo 13:00
  for (DateTime time = morningStart.add(Duration(hours: 10)); time.isBefore(morningEnd); time = time.add(Duration(minutes: 10))) {
    int alarmId = 1;
    AndroidAlarmManager.oneShotAt(time, alarmId, checkAndNotifyTasks, exact: true, wakeup: true);
  }
} */

 void checkAndNotifyTasks() async {  // tarkistetaan että tehtävät on tehny, palauttaa 'true'
  bool areTasksDone = await DatabaseHelper.areAllTasksDone();
  if (!areTasksDone) {
    _showNotification();
  }
} 

/* void scheduleDailyTaskReset() {
  final int alarmId = 1;
  final DateTime now = DateTime.now();
  final DateTime firstInstance = DateTime(now.year, now.month, now.day, 5);
  final DateTime alarmTime = firstInstance.isBefore(now) ? firstInstance.add(Duration(minutes: 1)) : firstInstance;
  
AndroidAlarmManager.periodic(
  const Duration(minutes: 1), // Testausta varten, vaihda takaisin sopivaan arvoon myöhemmin
  alarmId,
  resetDailyTasks,
  startAt: alarmTime,
  exact: true,
  wakeup: true,
);
} */


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

