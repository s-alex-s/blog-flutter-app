import 'package:blog/ui_components/blogs_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Query? _query;
  late TextEditingController _controller;
  late UniqueKey myKey;

  void _updateSearch(value) {}

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    myKey = UniqueKey();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
                controller: _controller,
                onChanged: (value) => setState(() {
                      _query = _db
                          .collection('blogs')
                          .where('title', isGreaterThanOrEqualTo: value.trim())
                          .where('title',
                              isLessThanOrEqualTo: '${value.trim()}\uf8ff');
                      myKey = UniqueKey();
                    }),
                maxLength: 50,
                decoration: const InputDecoration(
                    hintText: 'Поиск по названию',
                    suffixIcon: Icon(Icons.search))),
          ),
        ),
        _controller.text.trim().isNotEmpty
            ? Expanded(
                flex: 4,
                child: BlogsList(
                  perPage: 10,
                  query: _query!,
                  key: myKey,
                ))
            : const Spacer()
      ],
    );
  }
}
