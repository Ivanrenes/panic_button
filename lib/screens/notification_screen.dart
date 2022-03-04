import 'package:flutter/material.dart';
import 'package:panic_button_app/widgets/custom_appbar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: Text('NOTIFICACIONES'),
          iconTitle: Icon(Icons.notifications),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.refresh))],
        ),
        body: ListView(
          children: List<int>.from([1, 2, 3, 4, 5])
              .map((e) => NotificationCard())
              .toList(),
        ));
  }
}

Widget NotificationCard() {
  return Padding(
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Titulo de la notificación",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                "Cuerpo de la notificación",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
