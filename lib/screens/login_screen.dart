import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:panic_button_app/blocs/location/location_bloc.dart';
import 'package:panic_button_app/helpers/validators.dart';
import 'package:panic_button_app/providers/login_form_provider.dart';
import 'package:panic_button_app/providers/signup_form_provider.dart';
import 'package:panic_button_app/services/services.dart';
import 'package:provider/provider.dart';

import 'package:panic_button_app/ui/input_decorations.dart';
import 'package:panic_button_app/widgets/widgets.dart';

import '../blocs/gps/gps_bloc.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LocationBloc locationBloc;

  @override
  void initState() {
    super.initState();

    locationBloc = BlocProvider.of<LocationBloc>(context);
    locationBloc.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider(
      create: (_) => LoginFormProvider(),
      child: AuthBackground(
          child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 250),
            CardContainer(
                child: Column(
              children: [
                SizedBox(height: 10),
                Text('Ingreso', style: Theme.of(context).textTheme.headline4),
                SizedBox(height: 20),
                _LoginForm()
              ],
            )),
            SizedBox(height: 50),
            BlocListener<LocationBloc, LocationState>(
              bloc: locationBloc = BlocProvider.of<LocationBloc>(context),
              listener: (context, state) async {
                final gpsBloc = BlocProvider.of<GpsBloc>(context);
                final signUpForm =
                    Provider.of<SignUpFormProvider>(context, listen: false);

                final isGpsPermissionGranted = await gpsBloc.askGpsAccess();

                if (isGpsPermissionGranted) {
                  signUpForm.location = {
                    "lat": state.lastKnownLocation?.latitude,
                    "lng": state.lastKnownLocation?.longitude
                  };
                }
              },
              child: TextButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, 'signup_step_one');
                  },
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          Colors.redAccent.withOpacity(0.1)),
                      shape: MaterialStateProperty.all(StadiumBorder())),
                  child: Text(
                    'Crear una nueva cuenta',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  )),
            ),
            SizedBox(height: 50),
          ],
        ),
      )),
    ));
  }
}

class _LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Padding(
      padding: EdgeInsets.all(10),
      child: Form(
        key: loginForm.formKey,
        child: Column(
          children: [
            IntlPhoneField(
              decoration: InputDecorations.authInputDecoration(
                  hintText: '3003543968',
                  labelText: 'Celular',
                  prefixIcon: Icons.lock_outline),
              initialCountryCode: 'CO',
              initialValue: loginForm.phoneNumber,
              countries: ["CO", "US"],
              validator: checkEmpty,
              autovalidateMode: AutovalidateMode.always,
              pickerDialogStyle: PickerDialogStyle(
                  searchFieldInputDecoration:
                      InputDecoration(label: Text("Buscar país"))),
              onChanged: (phone) {
                loginForm.phoneNumber = '${phone.countryCode}${phone.number}';
              },
              invalidNumberMessage: "Este número no es valido",
            ),
            SizedBox(height: 10),
            MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                disabledColor: Colors.grey,
                elevation: 0,
                color: Colors.redAccent,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    child: Text(
                      loginForm.isLoading ? 'Espere' : 'Ingresar',
                      style: TextStyle(color: Colors.white),
                    )),
                onPressed: loginForm.isLoading
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        final authService =
                            Provider.of<AuthService>(context, listen: false);

                        if (!loginForm.isValidForm()) return;
                        print(loginForm.isValidForm());

                        loginForm.isLoading = true;

                        final errorMessage =
                            await authService.login(loginForm.phoneNumber);

                        if (authService.isValidUser) {
                          Navigator.pushReplacementNamed(context, 'checkOtp');
                        } else {
                          //TODO CHANGE TO VALIDATE ERROR
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            title: 'Oops...',
                            text: errorMessage,
                            loopAnimation: false,
                          );

                          loginForm.isLoading = false;
                        }
                      })
          ],
        ),
      ),
    );
  }
}
