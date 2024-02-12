import 'package:flutter/material.dart';

AppBar blogAppBar() {
    return AppBar(
      title: const CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage('assets/B_logo.png'),
      ),
      centerTitle: true,
    );
  }