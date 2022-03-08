import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:panic_button_app/blocs/blocs.dart';
import 'package:panic_button_app/constants/texts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GpsPermissionsPage extends StatelessWidget {
  const GpsPermissionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Container(
            margin: EdgeInsets.only(bottom: size * 0.1, top: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: const Image(image: AssetImage("assets/location.png")),
                  height: 240,
                ),
                Text(
                  TextConstants.gpstitle,
                  style: const TextStyle(color: Colors.black, fontSize: 25),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    TextConstants.gpsMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.black, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  margin: const EdgeInsets.only(
                    top: 15,
                    left: 20,
                    right: 20,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                BlocBuilder<GpsBloc, GpsState>(builder: (context, state) {
                  return !state.isGpsEnabled ? _EnableGPS() : _Location();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EnableGPS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            title: TextConstants.ops,
            text: TextConstants.enableGpsMessage,
            loopAnimation: false,
          );
        },
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.orangeAccent),
            width: 200,
            height: 50,
            child: Center(
                child: Text(TextConstants.enabeGpsTitle,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)))));
  }
}

class _Location extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final gpsBloc = BlocProvider.of<GpsBloc>(context);
    return GestureDetector(
        onTap: () async {
          bool isGranted = await gpsBloc.askGpsAccess();
          final sharedPrefs = await _prefs;
          if (isGranted) {
            await sharedPrefs.setBool("GPSPermisionGranted", true);
            Navigator.pushNamed(context, 'login');
          }
        },
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 177, 19, 16)),
            width: 200,
            height: 50,
            child: Center(
                child: Text(TextConstants.useMyLocation,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)))));
  }
}
