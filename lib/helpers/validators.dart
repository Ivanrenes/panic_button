String? checkEmpty(value) {
  if (value != null && value.length > 0) {
    return null;
  }
  return 'Este campo no puede quedar vacio';
}

String? isValidEmail(value) {
  return RegExp(
              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
          .hasMatch(value)
      ? null
      : 'Email is not valid';
}
