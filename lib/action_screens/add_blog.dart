import 'package:blog/ui_components/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddBlog extends StatefulWidget {
  const AddBlog({super.key});

  @override
  State<AddBlog> createState() => _AddBlogState();
}

class _AddBlogState extends State<AddBlog> {
  late TextEditingController _controllerText;
  late TextEditingController _controllerTitle;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  late FocusNode _focusNode;

  String? _textValidator(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Обязательное поле';
    }
    return null;
  }

  void _sendData() {
    _db.collection('blogs').add(<String, dynamic>{
      'date': DateTime.now(),
      'text': _controllerText.text.trim(),
      'title': _controllerTitle.text.trim(),
      'uuid': _auth.currentUser!.uid,
    });

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _controllerText = TextEditingController();
    _controllerTitle = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _controllerText.dispose();
    _controllerTitle.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double padd = 20.0;

    return Scaffold(
      appBar: blogAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(
            top: padd, left: padd, right: padd, bottom: 80),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _controllerTitle,
                validator: (value) => _textValidator(value),
                onFieldSubmitted: (value) => _focusNode.requestFocus(),
                autofocus: true,
                maxLength: 50,
                maxLines: null,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "Название",
                  border: OutlineInputBorder(),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              TextFormField(
                controller: _controllerText,
                validator: (value) => _textValidator(value),
                maxLines: null,
                focusNode: _focusNode,
                keyboardType: TextInputType.multiline,
                maxLength: 8000,
                decoration: const InputDecoration(

                  labelText: 'Текст'
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _sendData();
          }
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}
