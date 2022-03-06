import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:panic_button_app/helpers/validators.dart';
import 'package:panic_button_app/models/user.dart';
import 'package:panic_button_app/providers/signup_form_provider.dart';
import 'package:panic_button_app/services/push_notifications_service.dart';
import 'package:provider/provider.dart';

import 'dart:io' show File, Platform;

import 'package:panic_button_app/providers/login_form_provider.dart';
import 'package:panic_button_app/services/services.dart';

import 'package:panic_button_app/ui/input_decorations.dart';
import 'package:panic_button_app/widgets/widgets.dart';

class SignUpStepThreeScreen extends StatelessWidget {
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
            const SizedBox(height: 250),
            CardContainer(
                child: Column(
              children: [
                const SizedBox(height: 10),
                Text('¡Registro Completado!',
                    style: Theme.of(context).textTheme.headline5),
                const SizedBox(height: 5),
                Text('¿Desea agregar una foto de perfil?',
                    style: Theme.of(context).textTheme.headline6),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _SignUpStepThreeForm(),
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
                child: const Text(
                  '¿Ya tienes una cuenta?',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                )),
            const SizedBox(height: 50),
          ],
        ),
      ),
    )));
  }
}

class _SignUpStepThreeForm extends StatefulWidget {
  @override
  State<_SignUpStepThreeForm> createState() => _SignUpStepThreeFormState();
}

class _SignUpStepThreeFormState extends State<_SignUpStepThreeForm> {
  XFile? imageFile;
  @override
  Widget build(BuildContext context) {
    final signUpForm = Provider.of<SignUpFormProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final ImagePicker _picker = ImagePicker();

    void _openGallery(BuildContext context) async {
      XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        imageFile = pickedFile!;
      });

      Navigator.pop(context);
    }

    void _openCamera(BuildContext context) async {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      // Pick a video
      setState(() {
        imageFile = pickedFile!;
      });
      Navigator.pop(context);
    }

    Future<void> _showChoiceDialog(BuildContext context) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "Elige una opción",
                style: TextStyle(color: Colors.blue),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    const Divider(
                      height: 1,
                      color: Colors.blue,
                    ),
                    ListTile(
                      onTap: () {
                        _openGallery(context);
                      },
                      title: const Text("Gallery"),
                      leading: const Icon(
                        Icons.account_box,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: Colors.blue,
                    ),
                    ListTile(
                      onTap: () {
                        _openCamera(context);
                      },
                      title: const Text("Camera"),
                      leading: const Icon(
                        Icons.camera,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    }

    return Container(
      child: Form(
        key: signUpForm.formKeyThree,
        child: Column(
          children: [
            const SizedBox(height: 10),
            MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                disabledColor: Colors.grey,
                elevation: 0,
                color: Colors.green,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    child: Text(
                      signUpForm.isLoading ? 'Espere' : 'Seleccionar',
                      style: const TextStyle(color: Colors.white),
                    )),
                onPressed: () async {
                  await _showChoiceDialog(context);
                }),
            TextButton(
              child: const Text("Saltar por ahora",
                  style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.popAndPushNamed(context, 'home');
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    disabledColor: Colors.grey,
                    elevation: 0,
                    color: Colors.redAccent,
                    child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                        child: Text(
                          signUpForm.isLoading ? 'Espere' : 'Subir foto',
                          style: const TextStyle(color: Colors.white),
                        )),
                    onPressed: !signUpForm.isLoading
                        ? () async {
                            signUpForm.isLoading = true;
                            await authService.uploadImageToFirebase(
                                context, File(imageFile!.path));
                            await authService.updateProfilePicture(authService.imagePath);
                            signUpForm.isLoading = false;
                            authService.userLogged.avatar =
                                authService.imagePath;
                            Navigator.popAndPushNamed(context, 'home');
                          }
                        : null)
              ],
            )
          ],
        ),
      ),
    );
  }
}
