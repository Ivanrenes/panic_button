import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static StreamController<Map<String, dynamic>> _messageStream =
      StreamController.broadcast();
  static Stream<Map<String, dynamic>> get messagesStream =>
      _messageStream.stream;

  static Future _backgroundHandler(RemoteMessage message) async {
    // print( 'onBackground Handler ${ message.messageId }');
    print(message.data);
    _messageStream.add({
      "title": message.notification?.title ?? 'No title',
      "body": message.notification?.body ?? 'No body'
    });
  }

  static Future _onMessageHandler(RemoteMessage message) async {
    // print( 'onMessage Handler ${ message.messageId }');
    print(message.data);
    _messageStream.add({
      "title": message.notification?.title ?? 'No title',
      "body": message.notification?.body ?? 'No body'
    });
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    // print( 'onMessageOpenApp Handler ${ message.messageId }');
    print(message.data);
    _messageStream.add({
      "title": message.notification?.title ?? 'No title',
      "body": message.notification?.body ?? 'No body'
    });
  }

  static Future initializeApp() async {
    // Push Notifications
    await requestPermission();

    token = await FirebaseMessaging.instance.getToken();

    print(token);

    // Handlers
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);

    // Local Notifications
  }

  // Apple / Web
  static requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    print('User push notification status ${settings.authorizationStatus}');
  }

  static closeStreams() {
    _messageStream.close();
  }
}
