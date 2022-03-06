import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:panic_button_app/helpers/validators.dart';
import 'package:panic_button_app/providers/users/edit_user_form_provider.dart';
import 'package:panic_button_app/services/auth_service.dart';
import 'package:panic_button_app/ui/input_decorations.dart';
import 'package:panic_button_app/widgets/card_container.dart';
import 'package:panic_button_app/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditUserProfileScreen extends StatelessWidget {
  const EditUserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userLogged = Provider.of<AuthService>(context).userLogged;

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Editar Perfil'),
        iconTitle: const Icon(Icons.person),
        actions: [
          SizedBox(
            width: size.width * 0.2,
          )
        ],
      ),
      body: ChangeNotifierProvider(
          create: (context) => EditUserFormProvider(
              userLogged.name,
              userLogged.lastname,
              userLogged.email,
              userLogged.address,
              userLogged.alias),
          child: _EditUserForm()),
    );
  }
}

class _EditUserForm extends StatelessWidget {
  const _EditUserForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editUserFormProvider = Provider.of<EditUserFormProvider>(context);
    final authService = Provider.of<AuthService>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
          height: 450,
          width: double.infinity,
          child: CardContainer(
            child: Form(
              key: editUserFormProvider.formKey,
              child: Column(
                children: [
                  TextFormField(
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    initialValue: editUserFormProvider.name,
                    decoration: InputDecorations.authInputDecoration(
                        hintText: 'John',
                        labelText: 'Nombres',
                        prefixIcon: Icons.person),
                    onChanged: (value) {
                      editUserFormProvider.name = value;
                    },
                    validator: checkEmpty,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    initialValue: editUserFormProvider.lastName,
                    decoration: InputDecorations.authInputDecoration(
                        hintText: 'Doe',
                        labelText: 'Apellidos',
                        prefixIcon: Icons.person),
                    onChanged: (value) {
                      editUserFormProvider.lastName = value;
                    },
                    validator: checkEmpty,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    initialValue: editUserFormProvider.alias,
                    decoration: InputDecorations.authInputDecoration(
                        hintText: 'Mi Vaquita S.A',
                        labelText: 'Nombre del establecimiento',
                        prefixIcon: Icons.business_outlined),
                    onChanged: (value) {
                      editUserFormProvider.alias = value;
                    },
                    validator: checkEmpty,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    initialValue: editUserFormProvider.address,
                    decoration: InputDecorations.authInputDecoration(
                        hintText: 'CL 45D N 4 32',
                        labelText: 'Dirección',
                        prefixIcon: Icons.home),
                    onChanged: (value) {
                      editUserFormProvider.address = value;
                    },
                    validator: checkEmpty,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    initialValue: editUserFormProvider.email,
                    decoration: InputDecorations.authInputDecoration(
                        hintText: 'john.doe@email.com',
                        labelText: 'Correo Electronico',
                        prefixIcon: Icons.email),
                    onChanged: (value) {
                      editUserFormProvider.email = value;
                    },
                    validator: isValidEmail,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      disabledColor: Colors.grey,
                      elevation: 0,
                      color: Colors.redAccent,
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          child: Text(
                            'Guardar Cambios',
                            style: TextStyle(color: Colors.white),
                          )),
                      onPressed: !editUserFormProvider.isLoading
                          ? () async {
                              SharedPreferences _prefs =
                                  await SharedPreferences.getInstance();

                              editUserFormProvider.isLoading = true;
                              final res = await authService.updateUser(
                                  editUserFormProvider.email,
                                  editUserFormProvider.alias,
                                  editUserFormProvider.address,
                                  editUserFormProvider.name,
                                  editUserFormProvider.lastName);

                              res
                                  ? {
                                      authService.userLogged.email =
                                          editUserFormProvider.email,
                                      authService.userLogged.alias =
                                          editUserFormProvider.alias,
                                      authService.userLogged.address =
                                          editUserFormProvider.address,
                                      authService.userLogged.name =
                                          editUserFormProvider.name,
                                      authService.userLogged.lastname =
                                          editUserFormProvider.lastName,
                                      _prefs.setString(
                                          'userLogged',
                                          json.encode(
                                              authService.userLogged.toJson())),
                                      CoolAlert.show(
                                          context: context,
                                          type: CoolAlertType.success,
                                          title: '¡Felicidades!',
                                          text:
                                              "Tu perfil ha sido modificado exitosamente",
                                          loopAnimation: false)
                                    }
                                  : CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.error,
                                      title: '¡Lo sentimos!',
                                      text: "Húbo un error al intentar guardar",
                                      loopAnimation: false);

                              editUserFormProvider.isLoading = false;
                            }
                          : null)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
