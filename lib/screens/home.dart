import 'package:blog/ui_components/blogs_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    return BlogsList(
        query: db.collection("blogs").orderBy("date", descending: true),
        perPage: 15);
  }
}
