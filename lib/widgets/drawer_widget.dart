import 'package:flutter/material.dart';
import 'package:panic_button_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [_buildHeader(context), _buildMenuItems(context)],
      )),
    );
  }
}

Widget _buildHeader(BuildContext context) {
  final authService = Provider.of<AuthService>(context);

  return DrawerHeader(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: UserAccountsDrawerHeader(
        decoration: BoxDecoration(color: Colors.red[400]),
        currentAccountPicture: ClipOval(
            child: CircleAvatar(
                backgroundColor: Colors.blueGrey,
                backgroundImage: authService.userLogged.avatar != ''
                    ? FadeInImage.assetNetwork(
                            placeholder: 'assets/jar-loading.gif',
                            image: '${authService.userLogged.avatar}')
                        .image
                    : AssetImage('assets/no-image.png'))),
        accountName: Text(
            "${authService.userLogged.name} ${authService.userLogged.lastname} | ${authService.userLogged.alias}"),
        accountEmail: Text(
            '${authService.userLogged.email} | ${authService.userLogged.phone}'),
      ));
}

Widget _buildMenuItems(BuildContext context) {
  final authService = Provider.of<AuthService>(context);

  return Column(
    children: [
      ListTile(
        leading: const Icon(Icons.home),
        title: const Text("Home"),
        onTap: () {},
      ),
      ListTile(
        leading: const Icon(Icons.person_pin_rounded),
        title: const Text("Perfil"),
        onTap: () {
          Navigator.pushNamed(context, 'edit_user_profile');
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text("Cerrar Sesión"),
        onTap: () async {
          await authService.logout();
          Navigator.pushNamedAndRemoveUntil(
              context, 'login', (Route route) => false);
        },
      )
    ],
  );
}
