import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:panic_button_app/models/device.dart';

class SignUpFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKeyOne = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyTwo = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyThree = GlobalKey<FormState>();

  String phone = '';
  String address = '';
  String alias = '';
  String avatar = '';
  String city = '';
  String countryCode = '';
  String departament = '';
  String email = '';
  String name = '';
  String lastName = '';
  List<Device> devices = [];

  Map<String, dynamic> location = {};
  String zipCode = '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _administrator = false;
  bool get administrator => _administrator;

  set administrator(bool value) {
    _administrator = value;
    notifyListeners();
  }
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidStepOneForm() {
    return formKeyOne.currentState?.validate() ?? false;
  }

  bool isValidStepTwoForm() {
    return formKeyTwo.currentState?.validate() ?? false;
  }
}
