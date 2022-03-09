import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:panic_button_app/services/notifications_service.dart';
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
            return BlocBuilder<LocationBloc, LocationState>(
              builder: (context, locationState) {
                return BlocBuilder<MapBloc, MapState>(
                  builder: (context, mapState) {
                    return Stack(children: [
                      state.isAllGranted
                          ? MapView(
                              markers: mapState.markers,
                              initialLocation:
                                  locationState.lastKnownLocation ??
                                      LatLng(0, 0),
                            )
                          : Text(TextConstants.await),
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
                                      if (res.statusCode == 201 &&
                                          json.decode(res.body)['success']) {
                                        title = TextConstants.alertTitleSuccess;
                                        message =
                                            TextConstants.alertMessageSuccess;
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
                );
              },
            );
          },
        ));
  }
}

class MapView extends StatefulWidget {
  final LatLng initialLocation;
  final Set<Marker> markers;

  const MapView(
      {Key? key, required this.initialLocation, required this.markers})
      : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  BitmapDescriptor? myIcon;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), "assets/marker-icon.png")
        .then((onValue) {
      myIcon = onValue;
    });

    // widget.markers.add(Marker(
    //     markerId: MarkerId(widget.initialLocation.toString()),
    //     position: LatLng(
    //         widget.initialLocation.latitude, widget.initialLocation.longitude),
    //     icon: BitmapDescriptor.defaultMarker,
    //     infoWindow: const InfoWindow(
    //       title: "Your current position",
    //     )));
  }

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
          markers: widget.markers,
          zoomControlsEnabled: true,
          tileOverlays: const {},
          onMapCreated: (controller) =>
              mapBloc.add(OnMapInitializedEvent(controller)),
        );
        // return StreamBuilder<QuerySnapshot>(
        //     stream: _notificationService.notificationsStream,
        //     builder: (context, snapshot) {
        //       if (snapshot.hasData && snapshot.data!.size > 0) {
        //         snapshot.data!.docs.map((DocumentSnapshot document) {
        //           Map<String, dynamic> data =
        //               document.data()! as Map<String, dynamic>;

        //         });
        //         print(_markers);
        //       }

        //     });
      },
    );
  }
}
