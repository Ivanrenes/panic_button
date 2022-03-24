import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:panic_button_app/helpers/http_requests.dart';
import 'package:panic_button_app/models/panic.dart';

class PanicService extends ChangeNotifier {
  HttpService http = HttpService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  Future<Response> sendPanicNotification(Panic panic) async {
    Response res = await http.post(
        endpoint: '/api/push',
        body: json.encode(panic.toJson()),
        params: {});
    return res;
  }
}
