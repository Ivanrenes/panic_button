import 'package:panic_button_app/constants/texts.dart';

String? checkEmpty(value) {
  if (value != null && value.length > 0) {
    return null;
  }
  return TextConstants.canNotBeEmpty;
}

String? isValidEmail(value) {
  return RegExp(
              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
          .hasMatch(value)
      ? null
      : TextConstants.invalidEmail;
}
