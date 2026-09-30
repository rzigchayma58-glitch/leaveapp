import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

class NotificationService {
  static final _local = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static bool _welcomeShown = false;
  static bool _fcmReady = false;

  static const _channel = AndroidNotificationChannel(
    'xtensus_welcome',
    'Bienvenue Xtensus',
    description: 'Notifications XCongés',
    importance: Importance.high,
  );

  static Future<void> init() async {
    if (_ready) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin = _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();

    await _local
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      final token = await messaging.getToken();
      print('FCM token: $token');
      FirebaseMessaging.onMessage.listen((message) {
        final n = message.notification;
        if (n != null) {
          _show(n.title ?? 'XCongés', n.body ?? '');
        }
      });
      _fcmReady = true;
    } catch (e) {
      print(
        'FCM: ajoutez google-services.json (Firebase Console) pour le push distant. $e',
      );
    }

    _ready = true;
  }

  static Future<void> showWelcome({String? firstName}) async {
    if (_welcomeShown) return;
    try {
      await init();
      final name = firstName?.trim();
      final body = (name != null && name.isNotEmpty)
          ? 'Bienvenue chez Xtensus, $name'
          : 'Bienvenue chez Xtensus';
      _welcomeShown = true;
      await _show('XCongés', body);
    } catch (e) {
      print('Notification bienvenue: $e');
    }
  }

  static void resetWelcome() {
    _welcomeShown = false;
  }

  static bool get isFcmReady => _fcmReady;

  static Future<void> _show(String title, String body) async {
    await _local.show(
      1001,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
