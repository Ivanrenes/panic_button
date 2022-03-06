import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:panic_button_app/models/panic.dart';
import 'package:panic_button_app/widgets/custom_appbar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Stream<QuerySnapshot> _notificationsStream = FirebaseFirestore.instance
      .collection('panics')
      .orderBy('created')
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: Text('NOTIFICACIONES'),
          iconTitle: Icon(Icons.notifications),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.refresh))],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: _notificationsStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text(
                    'Algo no fue como lo esperabamos :(, por favor reporta con el administrador del sistema');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.redAccent,
                  ),
                );
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  Panic panic = Panic(
                      title: data["title"] ?? '',
                      body: data["body"] ?? '',
                      myLocation: data["myLocation"] ?? {},
                      name: data["name"] ?? '',
                      phone: data["phone"] ?? '',
                      alias: data["alias"]);

                  return NotificationCard(
                      title: panic.title,
                      description: panic.body,
                      alias: panic.alias,
                      name: panic.name);
                }).toList(),
              );
            }));
  }
}

Widget NotificationCard(
    {required title, required description, required name, required alias}) {
  return Container(
    padding: EdgeInsets.all(10),
    child: Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
          color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 10,
          ),
          Image.asset(
            "assets/55-error-outline.gif",
            height: 100,
          ),
          SizedBox(
            width: 10,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis),
                ),
                Text(
                  description,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis),
                ),
                Text(
                  "Persona: $name",
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis),
                ),
                Text(
                  "Empresa: $alias",
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
