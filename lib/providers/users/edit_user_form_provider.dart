import 'package:flutter/material.dart';

class EditUserFormProvider extends ChangeNotifier {
  EditUserFormProvider(
      this._name, this._lastName, this._email, this._address, this._alias);

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _name = '';
  String _lastName = '';
  String _email = '';
  String _address = '';
  String _alias = '';
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  String get name => _name;

  set name(String name) {
    _name = name;
    notifyListeners();
  }

  String get lastName => _lastName;

  set lastName(String lastName) {
    _lastName = lastName;
    notifyListeners();
  }

  String get email => _email;

  set email(String email) {
    _email = email;
    notifyListeners();
  }

  String get address => _address;

  set address(String address) {
    _address = address;
    notifyListeners();
  }

  String get alias => _alias;

  set alias(String alias) {
    _alias = alias;
    notifyListeners();
  }

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }
}
