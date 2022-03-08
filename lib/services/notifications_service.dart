import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsService extends ChangeNotifier {
  Stream<QuerySnapshot> _notificationsStream = FirebaseFirestore.instance
      .collection('panics')
      .where('expiration_time',
          isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
      .orderBy('expiration_time')
      .snapshots();

  Stream<QuerySnapshot> get notificationsStream => _notificationsStream;

  set notificationsStream(Stream<QuerySnapshot> notificationsStream) {
    _notificationsStream = notificationsStream;
    notifyListeners();
  }

  NotificationsService() {
    Timer.periodic(Duration(seconds: 15), (timer) {
      notificationsStream = getNotificationsStream();
    });
  }

  getNotificationsStream() {
    return FirebaseFirestore.instance
        .collection('panics')
        .where('expiration_time',
            isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .orderBy('expiration_time')
        .snapshots();
  }
}

//Stream<QuerySnapshot> _notificationsStream = 