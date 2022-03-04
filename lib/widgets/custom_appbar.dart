import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar(
      {Key? key,
      required this.title,
      required this.iconTitle,
      required this.actions})
      : super(key: key);
  Widget title;
  Icon iconTitle;
  List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconTitle,
          SizedBox(
            width: 10,
          ),
          title
        ],
      )),
      actions: actions,
      backgroundColor: Colors.redAccent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
