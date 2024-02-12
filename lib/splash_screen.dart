import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'action_screens/get_user_info.dart';
import 'auth.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2000), () {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => const AuthScreen()));
      } else {
        _db
            .collection('profiles')
            .doc(_auth.currentUser?.uid)
            .get()
            .then((value) {
          if (!value.exists) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const GetUserInfoScreen(title: 'Давайте знакомиться', buttonText: 'Продолжить',)));
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => const Main()));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/B_logo.png'),
        ),
      ),
    );
  }
}
