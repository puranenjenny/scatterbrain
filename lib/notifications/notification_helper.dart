import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scatter_brain/notifications/shared_helper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Time {
  final int hour;
  final int minute;

  Time(this.hour, this.minute);
}

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

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

  //Vaihtoehto1:Ilmoitus5sekunninkuluttua
  static show5SecondsNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required tz.TZDateTime scheduledDate,
  })async=>
      _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        await _notificationDetails(),
        payload:payload,
        androidScheduleMode:AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:DateTimeComponents.time,
      );

  //aamuhälytykset
  static Future<void> scheduleMorningNotifications() async {
    String morningTime = "12:11";//await SharedPreferencesHelper.getString('selectedMorningTime');
    String frequency =  "1"; //await SharedPreferencesHelper.getString('selectedFrequency');
    bool notificationsEnabled = await SharedPreferencesHelper.getBool('notificationsEnabled');
    print('Scheduling morning notifications at $morningTime with frequency $frequency');

    if (!notificationsEnabled) return;

    List<String> timeParts = morningTime.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int notificationFrequency = int.parse(frequency);

    final now = tz.TZDateTime.now(tz.local);
    var morningDateTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (now.isAfter(morningDateTime)) { // tarkistetaan onko valittu kellonaika jo mennyt, jos on ajoitetaan huomiselle
      morningDateTime = morningDateTime.add(Duration(days: 1));
    }

    int maxNotifications = 10;// rajoitetaan ilmoitusten määrä korkeintaan 10:een

    for (int i = 0; i < maxNotifications; i++) {
      print("loopin sisällä");
      _notifications.zonedSchedule(
        1000 + i, // Ainutlaatuinen ID jokaiselle ilmoitukselle
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
  @pragma('vm:entry-point')
  static Future<void> scheduleEveningNotifications() async {
    String eveningTime = await SharedPreferencesHelper.getString('selectedEveningTime');
    String frequency = await SharedPreferencesHelper.getString('selectedFrequency');
    bool notificationsEnabled = await SharedPreferencesHelper.getBool('notificationsEnabled');
    print('Scheduling evening notifications at $eveningTime with frequency $frequency');

    if (!notificationsEnabled) return;

    List<String> timeParts = eveningTime.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int notificationFrequency = int.parse(frequency);

    final now = tz.TZDateTime.now(tz.local);
    var eveningDateTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (now.isAfter(eveningDateTime)) {
      eveningDateTime = eveningDateTime.add(Duration(days: 1));
    }

    int maxNotifications = 10;

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


  static Future<void> cancelMorningNotifications() async {
    // Tässä esimerkissä oletetaan, että aamun ilmoitusten ID:t alkavat 1000:sta.
    // Peruutetaan kaikki aamun ilmoitukset.
    for (int i = 1000; i < 2000; i++) {
      await _notifications.cancel(i);
    }
    print("Morning notifications cancelled.");
  }

  static Future<void> cancelEveningNotifications() async {
    // Tässä esimerkissä oletetaan, että illan ilmoitusten ID:t alkavat 2000:sta.
    // Peruutetaan kaikki illan ilmoitukset.
    for (int i = 2000; i < 3000; i++) {
      await _notifications.cancel(i);
    }
    print("Evening notifications cancelled.");
  }



}


