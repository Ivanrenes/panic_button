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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildHeader(context), _buildMenuItems(context)],
      )),
    );
  }
}

Widget _buildHeader(BuildContext context) {
  final authService = Provider.of<AuthService>(context);

  return SafeArea(
    child: DrawerHeader(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Colors.red[400]),
          currentAccountPicture: ClipOval(
              child: CircleAvatar(
                  backgroundImage: Image.network(
                          '${authService.userLogged.avatar}',
                          fit: BoxFit.cover)
                      .image)),
          accountName: Text(
              "${authService.userLogged.name} ${authService.userLogged.lastname} "),
          accountEmail: Text('${authService.userLogged.email}'),
        )),
  );
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
        title: const Text("Profile"),
        onTap: () {},
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text("Logout"),
        onTap: () async {
          await authService.logout();
          Navigator.pushNamedAndRemoveUntil(
              context, 'login', (Route route) => false);
        },
      )
    ],
  );
}
