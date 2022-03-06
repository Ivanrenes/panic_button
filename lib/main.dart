import 'dart:convert';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:panic_button_app/blocs/location/location_bloc.dart';
import 'package:panic_button_app/models/user.dart';
import 'package:panic_button_app/providers/signup_form_provider.dart';
import 'package:panic_button_app/screens/notification_screen.dart';
import 'package:panic_button_app/screens/signup/signup_step_three.dart';
import 'package:panic_button_app/screens/signup/signup_step_two_screen.dart';
import 'package:panic_button_app/screens/users/edit_user_profile_screen.dart';
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
import 'services/panic_service.dart';

bool? GPSPermissionGranted;
late final userLogged;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  GPSPermissionGranted = _prefs.getBool("GPSPermisionGranted");
  userLogged = _prefs.get('userLogged');

  await AwesomeNotifications().initialize(
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
    child: const AppState(),
  ));
}

class AppState extends StatefulWidget {
  const AppState({Key? key}) : super(key: key);

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
              title: const Text('Habilita las notificaciones'),
              content: const Text(
                  'Nuestra App funcióna gracias a la notificaciónes es IMPORTANTE activarlas'),
              actions: [
                TextButton(
                  onPressed: () => AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context)),
                  child: const Text(
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
      print('notificacion recibida $message');
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
        ChangeNotifierProvider(create: (_) => PanicService()),
        ChangeNotifierProvider(create: (_) => ProductsService()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (userLogged != null) {
      authService.userLoggedUnNotified = User.fromJson(json.decode(userLogged));
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Panic Button App',
      initialRoute: GPSPermissionGranted != true
          ? 'gps_permission'
          : userLogged != null
              ? 'home'
              : 'login',
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

        //Notifications Route
        'notification': (_) => NotificationScreen(),

        //Users Routes
        'edit_user_profile': (_) => EditUserProfileScreen()
      },
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
