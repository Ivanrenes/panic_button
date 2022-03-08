import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:panic_button_app/blocs/location/location_bloc.dart';
import 'package:panic_button_app/blocs/map/map_bloc.dart';
import 'package:panic_button_app/constants/texts.dart';
import 'package:panic_button_app/models/panic.dart';
import 'package:panic_button_app/models/user.dart';
import 'package:panic_button_app/services/auth_service.dart';
import 'package:panic_button_app/services/panic_service.dart';
import 'package:panic_button_app/widgets/drawer_widget.dart';
import 'package:provider/provider.dart';

import '../blocs/gps/gps_bloc.dart';
import '../widgets/panic_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late LocationBloc locationBloc;
  var title = TextConstants.alertTitleError;
  var message = TextConstants.alertMessageError;
  var typeAlert = CoolAlertType.error;

  @override
  void initState() {
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
    locationBloc.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final panicService = Provider.of<PanicService>(context);
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text(TextConstants.nameApp)),
          backgroundColor: const Color.fromARGB(255, 177, 19, 16),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'notification');
                },
                icon: const Icon(Icons.notifications))
          ],
        ),
        drawer: const DrawerMenu(),
        body: BlocBuilder<GpsBloc, GpsState>(
          builder: (context, state) {
            return Stack(children: [
              state.isAllGranted ? const MapView() : Text(TextConstants.await),
              Positioned(
                  top: size.height - 220,
                  left: size.width - 300,
                  child: PanicButton(
                      message: TextConstants.panicButton,
                      height: 80,
                      width: 200,
                      color: panicService.isLoading
                          ? Colors.blueGrey
                          : const Color.fromARGB(255, 177, 19, 16),
                      iconSize: 50,
                      icon: Icons.notifications,
                      radius: 100,
                      onClick: !panicService.isLoading
                          ? () async {
                              panicService.isLoading = true;
                              User userLogged = authService.userLogged;
                              Panic panicTo = Panic(
                                title:
                                    "${userLogged.alias} ${TextConstants.notificationTitle}",
                                body: TextConstants.notificationBody,
                                myLocation: userLogged.location,
                                name: userLogged.name,
                                phone: userLogged.phone,
                                alias: userLogged.alias,
                                zipCode: userLogged.zipCode,
                                countryCode: userLogged.countryCode,
                              );
                              // ignore: todo
                              //TODO: Sending notification without userId check if it is needed
                              Response res = await panicService
                                  .sendPanicNotification(panicTo);
                              // ignore: todo
                              //TODO: check validation error because is always true
                              if (res.statusCode == 201 && json.decode(res.body)['success']) {
                                title = TextConstants.alertTitleSuccess;
                                message = TextConstants.alertMessageSuccess;
                                typeAlert = CoolAlertType.success;
                              }
                              CoolAlert.show(
                                      context: context,
                                      type: typeAlert,
                                      title: title,
                                      text: message,
                                      loopAnimation: false);
                              panicService.isLoading = false;
                            }
                          : () {})),
            ]);
          },
        ));
  }
}

class MapView extends StatelessWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context);
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        if (state.lastKnownLocation == null) {
          return Center(child: Text(TextConstants.await));
        }
        return GoogleMap(
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: state.lastKnownLocation!,
            zoom: 16,
          ),
          zoomControlsEnabled: true,
          tileOverlays: const {},
          onMapCreated: (controller) =>
              mapBloc.add(OnMapInitialzedEvent(controller)),
        );
      },
    );
  }
}
