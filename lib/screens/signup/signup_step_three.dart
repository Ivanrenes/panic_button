import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panic_button_app/constants/texts.dart';
import 'package:panic_button_app/providers/signup_form_provider.dart';
import 'package:provider/provider.dart';

import 'dart:io' show File;

import 'package:panic_button_app/services/services.dart';

import 'package:panic_button_app/widgets/widgets.dart';

class SignUpStepThreeScreen extends StatelessWidget {
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 120,
    keepScrollOffset: true,
  );

  SignUpStepThreeScreen({Key? key}) : super(key: key);
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
                Text(TextConstants.completeRegister,
                    style: Theme.of(context).textTheme.headline5),
                const SizedBox(height: 5),
                Text(TextConstants.addProfileImage,
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
              title: Text(
                TextConstants.selectOption,
                style: const TextStyle(color: Colors.blue),
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
                      title: Text(TextConstants.gallery),
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
                      title: Text(TextConstants.camera),
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

    return Form(
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text(
                    signUpForm.isLoading ? TextConstants.await : TextConstants.select,
                    style: const TextStyle(color: Colors.white),
                  )),
              onPressed: () async {
                await _showChoiceDialog(context);
              }),
          TextButton(
            child: Text(TextConstants.skipForNow,
                style: const TextStyle(color: Colors.grey)),
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
                  color: const Color.fromARGB(255, 177, 19, 16),
                  child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      child: Text(
                        signUpForm.isLoading ? TextConstants.await : TextConstants.uploadPhoto,
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
    );
  }
}
