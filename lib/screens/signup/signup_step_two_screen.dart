import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:panic_button_app/helpers/validators.dart';
import 'package:panic_button_app/models/user.dart';
import 'package:panic_button_app/providers/signup_form_provider.dart';
import 'package:panic_button_app/services/push_notifications_service.dart';
import 'package:provider/provider.dart';

import 'dart:io' show Platform;

import 'package:panic_button_app/providers/login_form_provider.dart';
import 'package:panic_button_app/services/services.dart';

import 'package:panic_button_app/ui/input_decorations.dart';
import 'package:panic_button_app/widgets/widgets.dart';

class SignUpStepTwoScreen extends StatelessWidget {
  ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 120,
    keepScrollOffset: true,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AuthBackground(
            child: Center(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            SizedBox(height: 250),
            CardContainer(
                child: Column(
              children: [
                SizedBox(height: 10),
                Text('Información adiciónal',
                    style: Theme.of(context).textTheme.headline5),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _SignUpStepTwoForm(),
                ),
              ],
            )),
            SizedBox(height: 50),
            TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, 'login'),
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        Colors.indigo.withOpacity(0.1)),
                    shape: MaterialStateProperty.all(StadiumBorder())),
                child: Text(
                  '¿Ya tienes una cuenta?',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                )),
            SizedBox(height: 50),
          ],
        ),
      ),
    )));
  }
}

class _SignUpStepTwoForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final signUpForm = Provider.of<SignUpFormProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Container(
      child: Form(
        key: signUpForm.formKeyTwo,
        child: Column(
          children: [
            SizedBox(height: 10),
            TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'john.doe@email.com',
                    labelText: 'Email',
                    prefixIcon: Icons.email),
                onChanged: (value) => signUpForm.email = value,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: isValidEmail),
            SizedBox(height: 10),
            TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'CL 123 N 432',
                    labelText: 'Dirección',
                    prefixIcon: Icons.home),
                onChanged: (value) => signUpForm.address = value,
                validator: checkEmpty),
            SizedBox(height: 10),
            TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'Barranquilla',
                    labelText: 'Ciudad',
                    prefixIcon: Icons.location_city),
                onChanged: (value) => signUpForm.city = value,
                validator: checkEmpty),
            TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'Atlantico',
                    labelText: 'Departamento',
                    prefixIcon: Icons.location_city),
                onChanged: (value) => signUpForm.departament = value,
                validator: checkEmpty),
            SizedBox(height: 10),
            TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'Mi Vaquita S.A',
                    labelText: 'Nombre de establecimiento',
                    prefixIcon: Icons.business_outlined),
                onChanged: (value) => signUpForm.alias = value,
                validator: checkEmpty),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    disabledColor: Colors.grey,
                    elevation: 0,
                    color: Colors.blueGrey,
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        child: Text(
                          'Atras',
                          style: TextStyle(color: Colors.white),
                        )),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                SizedBox(
                  width: 10,
                ),
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    disabledColor: Colors.grey,
                    elevation: 0,
                    color: Colors.redAccent,
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        child: Text(
                          signUpForm.isLoading ? 'Espere' : 'Siguiente',
                          style: TextStyle(color: Colors.white),
                        )),
                    onPressed: () async {
                      if (!signUpForm.isValidStepTwoForm()) return;

                      final user = User(
                          phone: signUpForm.phone,
                          address: signUpForm.address,
                          alias: signUpForm.alias,
                          avatar: 'test.jgp',
                          city: signUpForm.city,
                          countryCode: signUpForm.countryCode,
                          departament: signUpForm.departament,
                          devices: [
                            {
                              "device": PushNotificationService.token,
                              "os": Platform.isAndroid ? "android" : "ios",
                              "created": DateTime.now().millisecond
                            }
                          ],
                          email: signUpForm.email,
                          name: signUpForm.name,
                          lastname: signUpForm.lastName,
                          zipCode: signUpForm.zipCode,
                          location: signUpForm.location);

                      await authService.signUp(user);
                      Navigator.pushNamed(context, 'checkOtp', arguments: user);
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
