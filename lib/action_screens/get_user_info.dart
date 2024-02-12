import 'package:blog/main.dart';
import 'package:blog/ui_components/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetUserInfoScreen extends StatefulWidget {
  const GetUserInfoScreen(
      {super.key, required this.title, required this.buttonText});

  final String title;
  final String buttonText;

  @override
  State<GetUserInfoScreen> createState() => _GetUserInfoScreenState();
}

class _GetUserInfoScreenState extends State<GetUserInfoScreen> {
  late TextEditingController _controller;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _validate = false;

  void _sendData() {
    if (_controller.text.trim().isNotEmpty) {
      _db
          .collection('profiles')
          .doc(_auth.currentUser!.uid)
          .set(<String, String>{
        'name': _controller.text.trim(),
        'avatar': _auth.currentUser!.photoURL!
      });

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(_controller.text.trim());
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Main()));
      }
    } else {
      setState(() {
        _validate = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: blogAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: _controller,
              maxLength: 25,
              onSubmitted: (value) => _sendData(),
              decoration: InputDecoration(
                labelText: "Отображаемое имя",
                errorText: _validate ? 'Обязательное поле' : null,
                border: const OutlineInputBorder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: FilledButton(
                  onPressed: () => _sendData(),
                  child: Text(
                    widget.buttonText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
