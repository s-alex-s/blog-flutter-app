import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main.dart' show Main;
import 'package:blog/action_screens/get_user_info.dart' show GetUserInfoScreen;

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool loading = false;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _signGoogle() {
    setState(() {
      loading = true;
    });

    signInWithGoogle()
        .whenComplete(() => setState(() {
              loading = false;
            }))
        .onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Ошибка авторизации'),
        action: SnackBarAction(label: 'Повтор', onPressed: () => _signGoogle()),
      ));
      throw error!;
    });
  }

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _db.collection('profiles').doc(user.uid).get().then((value) {
          if (!value.exists) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const GetUserInfoScreen(title: 'Давайте знакомиться', buttonText: "Продолжить",)));
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
    return Scaffold(
        body: Column(
      children: [
        const Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Авторизация',
                  style: TextStyle(fontSize: 30),
                )
              ],
            )),
        loading
            ? const Expanded(
                flex: 1,
                child: Center(child: CircularProgressIndicator()),
              )
            : const Spacer(),
        Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                    onPressed: () => _signGoogle(),
                    child: const Row(children: [
                      Padding(
                        padding: EdgeInsets.only(right: 9.0),
                        child: Image(
                          image: AssetImage('assets/google-logo1024.png'),
                          width: 30,
                        ),
                      ),
                      Text(
                        'Войти с помощью Google',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ]))
              ],
            ))
      ],
    ));
  }
}
