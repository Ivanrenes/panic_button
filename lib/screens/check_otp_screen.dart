import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:panic_button_app/constants/texts.dart';
import 'package:panic_button_app/models/user.dart';
import 'package:panic_button_app/services/services.dart';
import 'package:provider/provider.dart';

import 'package:panic_button_app/widgets/widgets.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';


class CheckOtpScreen extends StatelessWidget {
  const CheckOtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments;

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
                Center(
                  child: Text(TextConstants.verificationCode,
                      style: Theme.of(context).textTheme.headline5),
                ),
                const SizedBox(height: 20),
                _otpVerificationForm()
              ],
            )),
            const SizedBox(height: 50),
            TextButton(
                onPressed: () => {
                      if (user != null)
                        {Navigator.of(context).pop()}
                      else
                        {Navigator.popAndPushNamed(context, 'login')}
                        
                    },
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 177, 19, 16)),
                    shape: MaterialStateProperty.all(const StadiumBorder())),
                child: Text(
                  TextConstants.back,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                )),
            const SizedBox(height: 50),
          ],
        ),
      )),
    );
  }
}

class _otpVerificationForm extends StatelessWidget {
  _otpVerificationForm({Key? key, this.user}) : super(key: key);
  User? user;
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = ModalRoute.of(context)!.settings.arguments;

    return OtpTextField(
      numberOfFields: 6,
      borderColor: const Color(0xFF512DA8),
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
                title: TextConstants.ops,
                text: TextConstants.failValidateCode,
                loopAnimation: false);
      }, // end onSubmit
    );
  }
}
