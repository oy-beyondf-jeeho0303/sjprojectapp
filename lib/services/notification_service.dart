import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones(); 

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // ❌ [틀린 코드] initialize(settings: initializationSettings, ...) 
    // ✅ [정답 코드] 이름표 없이 변수만 딱 넣어야 합니다!
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        print("알림 클릭됨: ${details.payload}");
      },
    );
  }

  Future<void> scheduleDaily7AMNotification() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 7, 0);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_fortune_channel', 
      '운세 알림', 
      channelDescription: '매일 아침 운세 알림',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
  //    iOS: DarwinNotificationDetails(),
    );


    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 0, // id: 추가
      title: '🌞 오늘의 운세가 도착했습니다!', // title: 추가
      body: '오늘 하루 주의할 점과 행운의 색을 확인해보세요.', // body: 추가
      scheduledDate: scheduledDate, // scheduledDate: 추가
      notificationDetails: notificationDetails, // notificationDetails: 추가
      
      // 아래 설정들은 이미 이름표가 있으므로 그대로 둡니다.
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

 
    print("✅ 알림 예약 완료: $scheduledDate");
  }
}