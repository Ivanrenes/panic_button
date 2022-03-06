import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:panic_button_app/helpers/validators.dart';
import 'package:panic_button_app/providers/signup_form_provider.dart';
import 'package:provider/provider.dart';

import 'package:panic_button_app/providers/login_form_provider.dart';
import 'package:panic_button_app/services/services.dart';

import 'package:panic_button_app/ui/input_decorations.dart';
import 'package:panic_button_app/widgets/widgets.dart';

class SignUpStepOneScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AuthBackground(
            child: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 250),
          CardContainer(
              child: Column(
            children: [
              const SizedBox(height: 10),
              Text('Crear cuenta',
                  style: Theme.of(context).textTheme.headline4),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _SignUpStepOneForm(),
              )
            ],
          )),
          const SizedBox(height: 50),
          TextButton(
              onPressed: () => Navigator.pop(context),
              style: ButtonStyle(
                  overlayColor:
                      MaterialStateProperty.all(Colors.indigo.withOpacity(0.1)),
                  shape: MaterialStateProperty.all(const StadiumBorder())),
              child: const Text(
                '¿Ya tienes una cuenta?',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              )),
          const SizedBox(height: 50),
        ],
      ),
    )));
  }
}

class _SignUpStepOneForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final signUpForm = Provider.of<SignUpFormProvider>(context);
    final authService = Provider.of<AuthService>(context);

    return Container(
      child: Form(
        key: signUpForm.formKeyOne,
        child: Column(
          children: [
            IntlPhoneField(
              decoration: InputDecorations.authInputDecoration(
                  hintText: '3003543968',
                  labelText: 'Celular',
                  prefixIcon: Icons.lock_outline),
              initialCountryCode: 'CO',
              initialValue: signUpForm.phone,
              countries: ["CO", "US"],
              validator: checkEmpty,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              pickerDialogStyle: PickerDialogStyle(
                  searchFieldInputDecoration:
                      const InputDecoration(label: const Text("Buscar país"))),
              onChanged: (phone) {
                signUpForm.phone = '${phone.countryCode}${phone.number}';
              },
              invalidNumberMessage: "Este número no es valido",
            ),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                  hintText: 'John',
                  labelText: 'Nombres',
                  prefixIcon: Icons.person),
              onChanged: (value) => signUpForm.name = value,
              validator: checkEmpty,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 10),
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                  hintText: 'Doe',
                  labelText: 'Apellidos',
                  prefixIcon: Icons.person),
              onChanged: (value) => signUpForm.lastName = value,
              validator: checkEmpty,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 30),
            MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                disabledColor: Colors.grey,
                elevation: 0,
                color: Colors.redAccent,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    child: Text(
                      signUpForm.isLoading ? 'Espere' : 'Siguiente',
                      style: const TextStyle(color: Colors.white),
                    )),
                onPressed: !signUpForm.isLoading
                    ? () async {
                        signUpForm.isLoading = true;
                        if (!signUpForm.isValidStepOneForm()) return;

                        await authService.verifyIsRegistered(signUpForm.phone);

                        if (authService.isRegistered == true) {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            title: 'Oops...',
                            text:
                                "Al parecer ya existe una cuenta con este numero, por favor inicia sesión",
                            loopAnimation: false,
                          );
                          signUpForm.isLoading = false;

                          return;
                        }

                        try {
                          List<Placemark> address =
                              await placemarkFromCoordinates(
                                  signUpForm.location["lat"],
                                  signUpForm.location["lng"]);
                          signUpForm.countryCode =
                              address.first.isoCountryCode!;
                          signUpForm.zipCode = address.first.postalCode ?? '';
                          Navigator.pushNamed(context, 'signup_step_two');
                        } catch (e) {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            title: 'Oops...',
                            text: e.toString(),
                            loopAnimation: false,
                          );
                        }
                        signUpForm.isLoading = false;
                      }
                    : null)
          ],
        ),
      ),
    );
  }
}
