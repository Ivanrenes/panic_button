import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:panic_button_app/constants/texts.dart';
import 'package:panic_button_app/models/panic.dart';
import 'package:panic_button_app/services/services.dart';
import 'package:panic_button_app/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _notificationService = Provider.of<NotificationsService>(context);
    return Scaffold(
        appBar: CustomAppBar(
          title: Text(TextConstants.notifications),
          iconTitle: const Icon(Icons.notifications),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.refresh))
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: _notificationService.notificationsStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text(TextConstants.genericError);
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 177, 19, 16),
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
                      alias: data["alias"],
                      countryCode: data["countryCode"]);

                  return notificationCard(
                      title: panic.title,
                      description: panic.body,
                      alias: panic.alias,
                      name: panic.name);
                }).toList(),
              );
            }));
  }
}

Widget notificationCard(
    {required title, required description, required name, required alias}) {
  return Container(
    padding: const EdgeInsets.all(10),
    child: Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 177, 19, 16),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 10,
          ),
          Image.asset(
            "assets/55-error-outline.gif",
            height: 100,
          ),
          const SizedBox(
            width: 10,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis),
                ),
                Text(
                  description,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis),
                ),
                Text(
                  "${TextConstants.person}: $name",
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis),
                ),
                Text(
                  "${TextConstants.company}: $alias",
                  maxLines: 2,
                  style: const TextStyle(
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
