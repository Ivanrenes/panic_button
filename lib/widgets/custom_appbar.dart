import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar(
      {Key? key,
      required this.title,
      required this.iconTitle,
      required this.actions})
      : super(key: key);
  final Widget title;
  final Icon iconTitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconTitle,
          const SizedBox(
            width: 10,
          ),
          title
        ],
      )),
      actions: actions,
      backgroundColor: const Color.fromARGB(255, 177, 19, 16),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
