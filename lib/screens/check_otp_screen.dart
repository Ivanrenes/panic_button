import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:panic_button_app/models/user.dart';
import 'package:panic_button_app/providers/login_form_provider.dart';
import 'package:panic_button_app/services/services.dart';
import 'package:provider/provider.dart';

import 'package:panic_button_app/ui/input_decorations.dart';
import 'package:panic_button_app/widgets/widgets.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../blocs/gps/gps_bloc.dart';

class CheckOtpScreen extends StatelessWidget {
  CheckOtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      body: AuthBackground(
          child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 250),
            CardContainer(
                child: Column(
              children: [
                SizedBox(height: 10),
                Center(
                  child: Text('Código de verificación',
                      style: Theme.of(context).textTheme.headline5),
                ),
                SizedBox(height: 20),
                _OtpVerificationForm()
              ],
            )),
            SizedBox(height: 50),
            TextButton(
                onPressed: () => {
                      if (user != null)
                        {Navigator.popAndPushNamed(context, 'login')}
                      else
                        {Navigator.popAndPushNamed(context, 'signup_step_two')}
                    },
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        Colors.redAccent.withOpacity(0.1)),
                    shape: MaterialStateProperty.all(StadiumBorder())),
                child: Text(
                  'Volver',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                )),
            SizedBox(height: 50),
          ],
        ),
      )),
    );
  }
}

class _OtpVerificationForm extends StatelessWidget {
  _OtpVerificationForm({Key? key, this.user}) : super(key: key);
  User? user;
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = ModalRoute.of(context)!.settings.arguments;

    return OtpTextField(
      numberOfFields: 6,
      borderColor: Color(0xFF512DA8),
      //set to true to show as box or false to show as dash
      showFieldAsBox: true,
      //runs when a code is typed in
      onCodeChanged: (String code) {
        //handle validation or checks here
      },
      //runs when every textfield is filled
      onSubmit: (String verificationCode) async {
        if (user != null) {
          await authService.verifyOtp(verificationCode, user);
        } else {
          await authService.verifyOtp(verificationCode, null);
        }

        authService.isValidOTP
            ? authService.isLogging
                ? Navigator.pushNamed(context, 'home')
                : Navigator.pushNamed(context, 'signup_step_three')
            : CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                title: 'Oops...',
                text:
                    "No pudimos validar tu codigo, por favor intenta nuevamente",
                loopAnimation: false);
      }, // end onSubmit
    );
  }
}
