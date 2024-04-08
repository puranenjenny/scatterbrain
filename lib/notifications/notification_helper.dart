import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  static Future _notificationDetails() async {
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

  // Vaihtoehto 1: Ilmoitus 5 sekunnin kuluttua
static show5SecondsNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required tz.TZDateTime scheduledDate, 
  }) async =>
    _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate, 
      await _notificationDetails(),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

  // Vaihtoehto 2: Ilmoitus joka päivä kello 10
  static Future showDailyNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    final scheduledDate = _ajastaDaily(Time(10, 0));
    return showAjastettuNotification(id: id, title: title, body: body, payload: payload, scheduledDate: scheduledDate);
  }

  // Apumetodit
  static Future showAjastettuNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required tz.TZDateTime scheduledDate,
    DateTimeComponents matchDateTimeComponents = DateTimeComponents.time,
  }) async =>
      _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        await _notificationDetails(),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
      );

  static tz.TZDateTime _ajastaDaily(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    return scheduledDate.isBefore(now) ? scheduledDate.add(const Duration(days: 1)) : scheduledDate;
  }



// sulje kaikki ilmoitukset
  static Future cancelAll() async {
    await _notifications.cancelAll();
  }


}


