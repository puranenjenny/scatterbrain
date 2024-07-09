import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scatter_brain/notifications/shared_helper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../database/database_helper.dart';


class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    var helsinki = tz.getLocation('Europe/Helsinki');
    tz.setLocalLocation(helsinki);

    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    tz.initializeTimeZones();
    await _notifications.initialize(initializationSettings);

  }

  static Future _notificationDetails() async { //tarvii
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'Scatterbrain',
        channelDescription: 'channel description',
        importance: Importance.max, // korkein prioriteetti
        icon: '@mipmap/ic_stat_paw',
        sound: RawResourceAndroidNotificationSound('sparkle'),
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationDetails(),
        payload: payload,
      );


  //aamuhälytykset
  static Future<void> scheduleMorningNotifications() async {
    var helsinki = tz.getLocation('Europe/Helsinki');
    final now = tz.TZDateTime.now(helsinki);
    String morningTime = await SharedPreferencesHelper.getString('selectedMorningTime');
    String frequency = await SharedPreferencesHelper.getString('selectedFrequency');
    bool notificationsEnabled = await SharedPreferencesHelper.getBool('notificationsEnabled');
    bool morningMessageShown = await SharedPreferencesHelper.getBool('morningMessageShown');
    print('Scheduling morning notifications at $morningTime with frequency $frequency');
    print("Current Helsinki time: ${tz.TZDateTime.now(tz.getLocation('Europe/Helsinki'))}");

    if (!notificationsEnabled || morningMessageShown) return;

    final dailys = await DatabaseHelper.getDailyTasks(); //tarkistetaan onko aamutehtäviä
    if (dailys == null) { //jos ei ole dailyja ollenkaan
      print("No tasks in database.");
      return;
    }
    final morningDailys = dailys.where((daily) => daily.timeOfDay == 'Morning').toList(); //laitetaan listaan
    if (morningDailys.isEmpty) { //jos lista on tyhjä
      print("No morning tasks, so no notifications.");
      return; //jos ei ole palataan takaisin
    }

    List<String> timeParts = morningTime.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int notificationFrequency = int.parse(frequency);

    var morningDateTime = tz.TZDateTime(helsinki, now.year, now.month, now.day, hour, minute);
    print(morningDateTime);

    if (now.isAfter(morningDateTime)) { // tarkistetaan onko valittu kellonaika jo mennyt, jos on ajoitetaan huomiselle
      morningDateTime = morningDateTime.add(Duration(days: 1));
    }

    int maxNotifications = 25;// rajoitetaan ilmoitusten määrä korkeintaan 25:een

    for (int i = 0; i < maxNotifications; i++) {
      print("aamuhälytysloopin sisällä");
      _notifications.zonedSchedule(
        1000 + i, // ainutlaatuinen ID jokaiselle ilmoitukselle
        "Hello there! 😊",
        "You have unfinished morning tasks! Do not sink in too deep before completing them!",
        morningDateTime.add(Duration(minutes: i * notificationFrequency)),
        await _notificationDetails(),
        payload: 'morning_notification_$i',
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }


  //iltahälytykset
  static Future<void> scheduleEveningNotifications() async {
    String eveningTime = await SharedPreferencesHelper.getString('selectedEveningTime');
    String frequency = await SharedPreferencesHelper.getString('selectedFrequency');
    bool notificationsEnabled = await SharedPreferencesHelper.getBool('notificationsEnabled');
    bool eveningMessageShown = await SharedPreferencesHelper.getBool('eveningMessageShown');
    print('Scheduling evening notifications at $eveningTime with frequency $frequency');

    if (!notificationsEnabled || eveningMessageShown) return;

    final dailys = await DatabaseHelper.getDailyTasks(); //tarkistetaan onko iltatehtäviä
    if (dailys == null) { //jos ei ole dailyja ollenkaan
      print("No tasks in database.");
      return;
    }
    final eveningDailys = dailys.where((daily) => daily.timeOfDay == 'Evening').toList(); //laitetaan listaan
    if (eveningDailys.isEmpty) {
      print("No evening tasks, so no notifications.");
      return;
    }

    List<String> timeParts = eveningTime.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int notificationFrequency = int.parse(frequency);

    var helsinki = tz.getLocation('Europe/Helsinki');
    final now = tz.TZDateTime.now(helsinki);
    var eveningDateTime = tz.TZDateTime(helsinki, now.year, now.month, now.day, hour, minute);

    if (now.isAfter(eveningDateTime)) {
      eveningDateTime = eveningDateTime.add(Duration(days: 1));
    }

    int maxNotifications = 25;

    for (int i = 0; i < maxNotifications; i++) {
      _notifications.zonedSchedule(
        2000 + i,
        "Good evening! 😊 ",
        "You have unfinished tasks! Try to get them done so you can relax!",
        eveningDateTime.add(Duration(minutes: i * notificationFrequency)),
        await _notificationDetails(),
        payload: 'evening_notification_$i',
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<void>cancelMorningNotifications()async{
    for(int i=1000;i<2000;i++){
      await _notifications.cancel(i);
    }
    print("Morningnotificationscancelled.");
  }

  static Future<void>cancelEveningNotifications()async{
    for(int i=2000;i<3000;i++){
      await _notifications.cancel(i);
    }
    print("Eveningnotificationscancelled.");
  }

}


