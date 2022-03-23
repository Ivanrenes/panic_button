import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:panic_button_app/blocs/location/location_bloc.dart';
import 'package:panic_button_app/constants/texts.dart';
import 'package:panic_button_app/models/user.dart';
import 'package:panic_button_app/providers/signup_form_provider.dart';
import 'package:panic_button_app/screens/notification_screen.dart';
import 'package:panic_button_app/screens/signup/signup_step_three.dart';
import 'package:panic_button_app/screens/signup/signup_step_two_screen.dart';
import 'package:panic_button_app/screens/users/edit_user_profile_screen.dart';
import 'package:panic_button_app/services/push_notifications_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        defaultColor: const Color.fromARGB(255, 177, 19, 16),
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
      BlocProvider(
          create: (context) =>
              MapBloc(locationBloc: BlocProvider.of<LocationBloc>(context))),
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

class _AppStateState extends State<AppState> with WidgetsBindingObserver{
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(TextConstants.enableNotifications),
              content: Text(TextConstants.messageToEnableNotifications),
              actions: [
                TextButton(
                  onPressed: () => AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context)),
                  child: Text(
                    TextConstants.allow,
                    style: const TextStyle(
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

    AwesomeNotifications().actionStream.listen(
      (ReceivedNotification receivedNotification){
          // Navigator.of(context).pushNamed(
          //     '/NotificationPage',
          //     arguments: {
          //         // your page params. I recommend you to pass the
          //         // entire *receivedNotification* object
          //         id: receivedNotification.id
          //     }
          // );

      }
    );
    PushNotificationService.messagesStream
        .listen((Map<String, dynamic> message) async {
          print('abrio notificación desde main');
    // FlutterAppBadger.updateBadgeCount(0);
    // FlutterAppBadger.removeBadge();
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
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      FlutterAppBadger.updateBadgeCount(1);
      Timer.periodic(const Duration(seconds: 5), (timer) {
        FlutterAppBadger.removeBadge();
        // print('remove');
      });
      // print('resummmeeennn');
    }
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
        ChangeNotifierProvider(
          create: (_) => NotificationsService(),
          lazy: false,
        )
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
    if (userLogged != null && userLogged.runtimeType != bool) {
      authService.userLoggedUnNotified = User.fromJson(json.decode(userLogged));
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: TextConstants.nameApp,
      initialRoute: GPSPermissionGranted != true
          ? 'gps_permission'
          : (userLogged != null && userLogged.runtimeType != bool)
              ? 'home'
              : 'login',
      routes: {
        'home': (_) => const HomeScreen(),
        'login': (_) => const LoginScreen(),
        'checkOtp': (_) => const CheckOtpScreen(),

        //SignUp Routes
        'signup_step_one': (_) => const SignUpStepOneScreen(),
        'signup_step_two': (_) => SignUpStepTwoScreen(),
        'signup_step_three': (_) => SignUpStepThreeScreen(),

        //onBoarding Routes
        'gps_permission': (_) => const GpsPermissionsPage(),

        //Notifications Route
        'notification': (_) => NotificationScreen(),

        //Users Routes
        'edit_user_profile': (_) => const EditUserProfileScreen()
      },
      theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.grey[300],
          appBarTheme: const AppBarTheme(elevation: 0, color: Colors.indigo),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.indigo, elevation: 0)),
    );
  }
}

int createUniqueId() {
  return Random().nextInt(1000);
}
