import 'package:flutter/material.dart';

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

Widget _buildHeader(BuildContext context) => SafeArea(
      child: DrawerHeader(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.red[400]),
            currentAccountPicture: ClipOval(
              child: const CircleAvatar(
                  radius: 100,
                  child: const Image(
                    image: const NetworkImage(
                        "https://scontent.fbaq2-2.fna.fbcdn.net/v/t39.30808-6/239353748_544632250205309_6498729261256858183_n.jpg?_nc_cat=107&ccb=1-5&_nc_sid=174925&_nc_eui2=AeGyyqRy4zJgSNOP_P3LvK4Qd014uSTVeB53TXi5JNV4HkIGUp-7na6qjmLZu19TXxVnkmeaJoZIn7NAPrQ9yIco&_nc_ohc=lds0RkFjtMAAX-xyYWl&_nc_ht=scontent.fbaq2-2.fna&oh=00_AT_anR4urFZY7PDvxSLsLsKYmZn2RtmFn5LOLCO6NIIg7A&oe=621B7184"),
                  )),
            ),
            accountName: const Text("Ivan Rodriguez"),
            accountEmail: const Text("ivanrenescorcia@gmail.com"),
          )),
    );
Widget _buildMenuItems(BuildContext context) => Column(
      children: [
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text("Home"),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Logout"),
          onTap: () {},
        )
      ],
    );
