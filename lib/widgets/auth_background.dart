import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:panic_button_app/providers/login_form_provider.dart';
import 'package:provider/provider.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          _RedBox(),
          _HeaderIcon(),
          this.child,
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatefulWidget {
  @override
  State<_HeaderIcon> createState() => _HeaderIconState();
}

class _HeaderIconState extends State<_HeaderIcon> {
  bool _headerIcon = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 30),
        child: Image(
          image: AssetImage('assets/55-error-outline.gif'),
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}

class _RedBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height * 0.4,
      decoration: _redBackground(),
      child: Stack(
        children: [
          Positioned(child: _Bubble(), top: 90, left: 30),
          Positioned(child: _Bubble(), top: -40, left: -30),
          Positioned(child: _Bubble(), top: -50, right: -20),
          Positioned(child: _Bubble(), bottom: -50, left: 10),
          Positioned(child: _Bubble(), bottom: 120, right: 20),
        ],
      ),
    );
  }

  BoxDecoration _redBackground() => BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.redAccent[400]!,
        Color.fromARGB(255, 221, 5, 48),
      ]));
}

class _Bubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Color.fromRGBO(255, 255, 255, 0.05)),
    );
  }
}
