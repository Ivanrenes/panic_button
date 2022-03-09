import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:panic_button_app/blocs/location/location_bloc.dart';
import 'package:panic_button_app/themes/map_style.dart';

import '../../themes/themes.dart';
import '../blocs.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  Set<Marker> _markers = {};

  final LocationBloc locationBloc;

  GoogleMapController? _mapController;

  StreamSubscription<LocationState>? locationSubscription;

  StreamSubscription<QuerySnapshot>? notificationsSubscription;

  BitmapDescriptor? myIcon;

  Set<Marker>? myMarkersParsed = {};

  MapBloc({required this.locationBloc}) : super(const MapState()) {
    on<OnMapInitializedEvent>(_onInitMap);

    on<OnStartFollowingUserEvent>(_onStartFollowingUser);
    on<OnStopFollowingUserEvent>(
        (event, emit) => emit(state.copyWith(isFollowingUser: false)));
    on<UpdateNotificationMarkerEvent>(_onNotificationNewNotification);

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), "assets/marker-icon.png")
        .then((onValue) {
      myIcon = onValue;
    });

    //GET INITIALS NOTIFICATIONS
    notificationsSubscription = FirebaseFirestore.instance
        .collection('panics')
        .where('expiration_time',
            isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .orderBy('expiration_time')
        .snapshots()
        .listen((event) {
      add(UpdateNotificationMarkerEvent(event));
    });

    //GET NOTIFICATIONS IN INTERVALS OF 15 TO KNOW IF SOME NOTIFICATIONS HAVE BEEN EXPIRED AND CLEAN THEM FROM THE MAPS
    Timer.periodic(Duration(seconds: 15), (timer) {
      notificationsSubscription = FirebaseFirestore.instance
          .collection('panics')
          .where('expiration_time',
              isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
          .orderBy('expiration_time')
          .snapshots()
          .listen((event) {
        add(UpdateNotificationMarkerEvent(event));
      });
    });
  }

  void _onInitMap(OnMapInitializedEvent event, Emitter<MapState> emit) {
    _mapController = event.controller;
    _mapController!.setMapStyle(jsonEncode(uberMapStyle));
    emit(state.copyWith(isMapInitialized: true));
  }

  void _onStartFollowingUser(
      OnStartFollowingUserEvent event, Emitter<MapState> emit) {
    emit(state.copyWith(isFollowingUser: true));
    if (locationBloc.state.lastKnownLocation == null) return;
    moveCamera(locationBloc.state.lastKnownLocation!);
  }

  void _onNotificationNewNotification(
      UpdateNotificationMarkerEvent event, Emitter<MapState> emit) {
    myMarkersParsed = <Marker>{};
    if (event.notifications.docs.isNotEmpty) {
      event.notifications.docs.forEach((notification) {
        myMarkersParsed!.add(Marker(
            markerId: MarkerId(notification.id),
            position: LatLng(notification["my_location"]["lat"],
                notification["my_location"]["lng"]),
            icon: myIcon ?? BitmapDescriptor.defaultMarker,
            infoWindow: const InfoWindow(
              title: "Panic Position",
            )));
      });
    }

    emit(state.copyWith(markers: myMarkersParsed));
  }

  void moveCamera(LatLng newLocation) {
    final cameraUpdate = CameraUpdate.newLatLng(newLocation);
    _mapController?.animateCamera(cameraUpdate);
  }

  @override
  Future<void> close() {
    locationSubscription?.cancel();
    return super.close();
  }
}
