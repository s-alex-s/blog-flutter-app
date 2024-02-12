import 'package:blog/ui_components/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ViewBlogScreen extends StatefulWidget {
  const ViewBlogScreen({super.key, required this.blogId});

  final String blogId;

  @override
  State<ViewBlogScreen> createState() => _ViewBlogScreenState();
}

class _ViewBlogScreenState extends State<ViewBlogScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DateFormat _formatter;
  bool _isSaved = false;

  void _saveBlog() {
    setState(() {
      _isSaved = !_isSaved;
    });

    _db
        .collection('saves')
        .where('uuid', isEqualTo: _auth.currentUser!.uid)
        .where('blog_id', isEqualTo: widget.blogId)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        _db.collection('saves').add(<String, String>{
          'uuid': _auth.currentUser!.uid,
          'blog_id': widget.blogId
        });
      } else {
        _db.collection('saves').doc(value.docs.first.id).delete();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    initializeDateFormatting("ru_RU");
    _formatter = DateFormat('dd MMM yyyy в HH:mm', "ru_RU");

    _db
        .collection('saves')
        .where('uuid', isEqualTo: _auth.currentUser!.uid)
        .where('blog_id', isEqualTo: widget.blogId)
        .count()
        .get()
        .then((value) {
      if (value.count == 0) {
        setState(() {
          _isSaved = false;
        });
      } else {
        setState(() {
          _isSaved = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double leftPadding = 12;

    return Scaffold(
      appBar: blogAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: _db.collection('blogs').doc(widget.blogId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else if (!snapshot.data!.exists) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Такого блога нет',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                        future: _db
                            .collection('profiles')
                            .doc(snapshot.data!.get('uuid'))
                            .get(),
                        builder: (context, snapshotAvatar) {
                          if (!snapshotAvatar.hasData) {
                            return const Row(
                              children: [
                                CircularProgressIndicator(),
                                Padding(
                                  padding: EdgeInsets.only(left: leftPadding),
                                  child: Text('Загрузка...'),
                                )
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                      snapshotAvatar.data!.get('avatar')),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: leftPadding),
                                  child: Text(
                                    snapshotAvatar.data!.get('name'),
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                )
                              ],
                            );
                          }
                        }),
                    const Padding(padding: EdgeInsets.only(top: 10)),
                    Text(
                      _formatter.format(snapshot.data!.get('date').toDate()),
                      style: const TextStyle(fontWeight: FontWeight.w200),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 15)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          snapshot.data!.get('title'),
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(snapshot.data!.get('text')),
                    const Padding(padding: EdgeInsets.only(top: 10)),
                    snapshot.data!.get('uuid') == _auth.currentUser!.uid
                        ? FilledButton(
                            onPressed: () {
                              _db
                                  .collection('blogs')
                                  .doc(snapshot.data!.id)
                                  .delete();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Удалить'))
                        : const SizedBox.shrink()
                    // const Padding(padding: EdgeInsets.only(top: 10)),
                    // IconButton(
                    //   onPressed: () => _saveBlog(),
                    //   icon: Icon(
                    //       _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    //       size: 35),
                    // )
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
