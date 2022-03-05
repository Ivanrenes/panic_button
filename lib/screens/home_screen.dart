import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:panic_button_app/blocs/location/location_bloc.dart';
import 'package:panic_button_app/blocs/map/map_bloc.dart';
import 'package:panic_button_app/widgets/drawer_widget.dart';
import 'package:permission_handler/permission_handler.dart';

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
                    color: Colors.red,
                    iconSize: 50,
                    icon: Icons.add_alert_sharp,
                    radius: 100,
                    onClick: (() {})),
              ),
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
