import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:panic_button_app/constants/texts.dart';

class PushNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static final StreamController<Map<String, dynamic>> _messageStream =
      StreamController.broadcast();
  static Stream<Map<String, dynamic>> get messagesStream =>
      _messageStream.stream;

  static Future _backgroundHandler(RemoteMessage message) async {
    _messageStream.add({
      "title": message.notification?.title ?? TextConstants.noTitle,
      "body": message.notification?.body ?? TextConstants.noBody
    });
  }

  static Future _onMessageHandler(RemoteMessage message) async {
    _messageStream.add({
      "title": message.notification?.title ?? TextConstants.noTitle,
      "body": message.notification?.body ?? TextConstants.noBody
    });
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    _messageStream.add({
      "title": message.notification?.title ?? TextConstants.noTitle,
      "body": message.notification?.body ?? TextConstants.noBody
    });
  }

  static Future initializeApp() async {
    // Push Notifications
    await requestPermission();

    token = await FirebaseMessaging.instance.getToken();

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
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
    } else if(settings.authorizationStatus == AuthorizationStatus.provisional){
    } else {
    }
    //for forerground
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true
    );
    // print('User push notification status ${settings.authorizationStatus}');
  }

  static closeStreams() {
    _messageStream.close();
  }
}
