import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:panic_button_app/widgets/drawer_widget.dart';

import '../blocs/gps/gps_bloc.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Panic Button'),
          backgroundColor: Colors.red[400],
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.notifications))
          ],
        ),
        drawer: const DrawerMenu(),
        body: BlocBuilder<GpsBloc, GpsState>(
          builder: (context, state) {
            return Stack(children: [
              state.isAllGranted ? MapView() : Text("Espere..."),
            ]);
          },
        ));
  }
}

class MapView extends StatelessWidget {
  const MapView({Key? key}) : super(key: key);

  static final CameraPosition IvanHouse = CameraPosition(
      target: LatLng(10.938986, -74.801250), zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: IvanHouse,
    );
  }
}
