import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:manga_reader_app/app/app_constants.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');


    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'manga_updates_channel',
      'Manga Updates',
      description: 'Notifications for new manga chapters',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNotification(String title, String body, int notificationIdCounter) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('manga_updates_channel', 'Manga Updates',
        channelDescription: 'Notifications for new manga chapters.',
        groupKey: AppConstants.groupKey,
        groupAlertBehavior: GroupAlertBehavior.children,
        importance: Importance.max,
        priority: Priority.defaultPriority,
        ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await FlutterLocalNotificationsPlugin().show(
      notificationIdCounter,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> showGroupSummaryNotification(int updatedCount) async {
    final String title = 'Library Updated';
    final String body = '$updatedCount manga${updatedCount > 1 ? 's' : ''} updated';

    final InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      ['Total Updated: $updatedCount'],
      contentTitle: title,
      summaryText: body,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('manga_updates_channel', 'Manga Updates',
        channelDescription: 'Notifications for new manga chapters.',
        groupKey: AppConstants.groupKey,
        setAsGroupSummary: true,
        styleInformation: inboxStyleInformation,
        importance: Importance.max,
        visibility: NotificationVisibility.public,
        priority: Priority.max);

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await FlutterLocalNotificationsPlugin().show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}