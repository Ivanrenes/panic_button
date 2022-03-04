import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:panic_button_app/blocs/location/location_bloc.dart';
import 'package:panic_button_app/providers/signup_form_provider.dart';
import 'package:panic_button_app/screens/notification_screen.dart';
import 'package:panic_button_app/screens/signup/signup_step_three.dart';
import 'package:panic_button_app/screens/signup/signup_step_two_screen.dart';
import 'package:panic_button_app/services/push_notifications_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

import 'package:panic_button_app/screens/screens.dart';
import 'package:panic_button_app/services/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/blocs.dart';
import 'screens/onboarding/gps_permission.dart';

bool? GPSPermissionGranted;
void main() async {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        defaultColor: Colors.redAccent,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
  );
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  GPSPermissionGranted = _prefs.getBool("GPSPermisionGranted");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await PushNotificationService.initializeApp();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => GpsBloc()),
      BlocProvider(create: (context) => LocationBloc()),
      BlocProvider(create: (context) => MapBloc()),
      // BlocProvider(
      //     create: (context) =>
      //         MapBloc(locationBloc: BlocProvider.of<LocationBloc>(context))),
    ],
    child: AppState(),
  ));
}

class AppState extends StatefulWidget {
  @override
  State<AppState> createState() => _AppStateState();
}

class _AppStateState extends State<AppState> {
  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Habilita las notificaciones'),
              content: Text(
                  'Nuestra App funcióna gracias a la notificaciónes es IMPORTANTE activarlas'),
              actions: [
                TextButton(
                  onPressed: () => AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context)),
                  child: Text(
                    'Permitir',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );

    PushNotificationService.messagesStream
        .listen((Map<String, dynamic> message) async {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: createUniqueId(),
          channelKey: 'basic_channel',
          title:
              '${Emojis.person_gesture_person_raising_hand + Emojis.sound_bell + message["title"]} !!!!',
          body: message["body"],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(
          create: (_) => SignUpFormProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ProductsService()),
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Panic Button App',
      initialRoute: GPSPermissionGranted != true ? 'gps_permission' : 'login',
      routes: {
        'home': (_) => HomeScreen(),
        'login': (_) => LoginScreen(),
        'checkOtp': (_) => CheckOtpScreen(),
        //SignUp Routes
        'signup_step_one': (_) => SignUpStepOneScreen(),
        'signup_step_two': (_) => SignUpStepTwoScreen(),
        'signup_step_three': (_) => SignUpStepThreeScreen(),

        //onBoarding Routes
        'gps_permission': (_) => GpsPermissionsPage(),

        //Notification Route
        'notification': (_) => NotificationScreen()
      },
      scaffoldMessengerKey: NotificationsService.messengerKey,
      theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.grey[300],
          appBarTheme: AppBarTheme(elevation: 0, color: Colors.indigo),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.indigo, elevation: 0)),
    );
  }
}

int createUniqueId() {
  return Random().nextInt(1000);
}
