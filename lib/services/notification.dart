import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotifService {
  final FlutterLocalNotificationsPlugin notifPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    AndroidInitializationSettings initSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    InitializationSettings initSettings =
        InitializationSettings(android: initSettingsAndroid);
    await notifPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse res) async {});
  }

  Future<bool> askPermission() async {
    bool? result = await notifPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return result??false;
  }

  notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails('연장 알림', '연장 알림',
          importance: Importance.max),
    );
  }

  Future<void> scheduleUsageTimeNotif({Duration duration = const Duration(hours:3, minutes: 30)}) async {
    await notifPlugin.cancelAll();
    return await notifPlugin.zonedSchedule(
        0, "도서관 이용시간 알림", "이용시간이 곧 종료됩니다. 퇴실시간을 확인하시고 연장하세요.",
        tz.TZDateTime.from(
            DateTime.now().add(duration), tz.local),
        await notificationDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
            .absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle);
  }

  Future<void> cancelUsageTimeNotif() async {
    await notifPlugin.cancel(0);
  }
}