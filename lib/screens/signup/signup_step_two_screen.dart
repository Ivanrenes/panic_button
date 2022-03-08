import 'package:flutter/material.dart';
import 'package:panic_button_app/constants/texts.dart';
import 'package:panic_button_app/helpers/validators.dart';
import 'package:panic_button_app/models/user.dart';
import 'package:panic_button_app/providers/signup_form_provider.dart';
import 'package:panic_button_app/services/push_notifications_service.dart';
import 'package:provider/provider.dart';

import 'dart:io' show Platform;

import 'package:panic_button_app/services/services.dart';

import 'package:panic_button_app/ui/input_decorations.dart';
import 'package:panic_button_app/widgets/widgets.dart';

class SignUpStepTwoScreen extends StatelessWidget {
  SignUpStepTwoScreen({Key? key}) : super(key: key);

  final ScrollController _scrollController = ScrollController(
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
            const SizedBox(height: 250),
            CardContainer(
                child: Column(
              children: [
                const SizedBox(height: 10),
                Text(TextConstants.additionalInformation,
                    style: Theme.of(context).textTheme.headline5),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _SignUpStepTwoForm(),
                ),
              ],
            )),
            const SizedBox(height: 50),
            TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, 'login'),
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        Colors.indigo.withOpacity(0.1)),
                    shape: MaterialStateProperty.all(const StadiumBorder())),
                child: Text(
                  TextConstants.readyAccount,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                )),
            const SizedBox(height: 50),
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

    return Form(
      key: signUpForm.formKeyTwo,
      child: Column(
        children: [
          const SizedBox(height: 10),
          TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                  hintText: TextConstants.testEmail,
                  labelText: TextConstants.email,
                  prefixIcon: Icons.email),
              onChanged: (value) => signUpForm.email = value,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: isValidEmail),
          const SizedBox(height: 10),
          TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecorations.authInputDecoration(
                  hintText: TextConstants.testAddress,
                  labelText: TextConstants.address,
                  prefixIcon: Icons.home),
              onChanged: (value) => signUpForm.address = value,
              validator: checkEmpty),
          const SizedBox(height: 10),
          TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecorations.authInputDecoration(
                  hintText: TextConstants.testCity,
                  labelText: TextConstants.city,
                  prefixIcon: Icons.location_city),
              onChanged: (value) => signUpForm.city = value,
              validator: checkEmpty),
          TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecorations.authInputDecoration(
                  hintText: TextConstants.testState,
                  labelText: TextConstants.state,
                  prefixIcon: Icons.location_city),
              onChanged: (value) => signUpForm.departament = value,
              validator: checkEmpty),
          const SizedBox(height: 10),
          TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecorations.authInputDecoration(
                  hintText: TextConstants.myBusiness,
                  labelText: TextConstants.nameBusiness,
                  prefixIcon: Icons.business_outlined),
              onChanged: (value) => signUpForm.alias = value,
              validator: checkEmpty),
          const SizedBox(height: 30),
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
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(
                        TextConstants.back,
                        style: const TextStyle(color: Colors.white),
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              const SizedBox(
                width: 10,
              ),
              MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledColor: Colors.grey,
                  elevation: 0,
                  color: const Color.fromARGB(255, 177, 19, 16),
                  child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(
                        signUpForm.isLoading ? TextConstants.await : TextConstants.next,
                        style: const TextStyle(color: Colors.white),
                      )),
                  onPressed: () async {
                    if (!signUpForm.isValidStepTwoForm()) return;

                    final user = User(
                        phone: signUpForm.phone,
                        address: signUpForm.address,
                        alias: signUpForm.alias,
                        avatar: TextConstants.testAvatar,
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
                        zipCode: int.tryParse(signUpForm.zipCode),
                        location: signUpForm.location);

                    await authService.signUp(user);
                    Navigator.pushNamed(context, 'checkOtp', arguments: user);
                  })
            ],
          )
        ],
      ),
    );
  }
}
