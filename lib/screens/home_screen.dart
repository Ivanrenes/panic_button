import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:panic_button_app/blocs/location/location_bloc.dart';
import 'package:panic_button_app/blocs/map/map_bloc.dart';
import 'package:panic_button_app/models/panic.dart';
import 'package:panic_button_app/models/user.dart';
import 'package:panic_button_app/services/auth_service.dart';
import 'package:panic_button_app/services/panic_service.dart';
import 'package:panic_button_app/widgets/drawer_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../blocs/gps/gps_bloc.dart';
import '../widgets/panic_button.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late LocationBloc locationBloc;

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
          title: Center(child: const Text('Panic Button')),
          backgroundColor: Colors.red[400],
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'notification');
                },
                icon: Icon(Icons.notifications))
          ],
        ),
        drawer: const DrawerMenu(),
        body: BlocBuilder<GpsBloc, GpsState>(
          builder: (context, state) {
            return Stack(children: [
              state.isAllGranted ? MapView() : Text("Espere..."),
              Positioned(
                  top: size.height - 220,
                  left: size.width - 300,
                  child: PanicButton(
                      message: "PANICO",
                      height: 80,
                      width: 200,
                      color: panicService.isLoading
                          ? Colors.blueGrey
                          : Colors.redAccent,
                      iconSize: 50,
                      icon: Icons.add_alert_sharp,
                      radius: 100,
                      onClick: !panicService.isLoading
                          ? () async {
                              panicService.isLoading = true;
                              User userLogged = authService.userLogged;
                              Panic panicTo = Panic(
                                title:
                                    "${userLogged.alias} dice: ¡Estoy en pánico!",
                                body:
                                    "Hay un evento peligroso que esta ocurriendo en cúrso",
                                myLocation: userLogged.location,
                                name: userLogged.name,
                                phone: userLogged.phone,
                                alias: userLogged.alias,
                                zipCode: userLogged.zipCode,
                              );
                              //TODO: Sending notification without userId check if it is needed
                              Response res = await panicService
                                  .sendPanicNotification(panicTo);

                              //TODO: check validation error because is always true
                              res.statusCode == 201
                                  ? CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.success,
                                      title: '¡Has enviado un panico!',
                                      text:
                                          "Se le ha reportado a todos los que se encuentran cerca del radio de tu compañia",
                                      loopAnimation: false)
                                  : CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.error,
                                      title: '¡Lo sentimos!',
                                      text: "El panico no púdo ser reportado",
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
        if (state.lastKnownLocation == null)
          return const Center(child: Text('Espere por favor...'));

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
