import 'package:blog/action_screens/edit_blog.dart';
import 'package:blog/screens/views/view_blog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class BlogsList extends StatefulWidget {
  const BlogsList({
    super.key,
    required this.query,
    required this.perPage,
    this.isEditable = false,
  });

  final Query query;
  final bool isEditable;
  final int perPage;

  @override
  State<BlogsList> createState() => _BlogsListState();
}

class _BlogsListState extends State<BlogsList> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<DocumentSnapshot> _blogs = [];
  late DocumentSnapshot _lastDoc;
  bool _loadingBlogs = false;
  late DateFormat _formatter;
  final ScrollController _scrollController = ScrollController();
  bool _gettingMoreBlogs = false;
  bool _moreBlogsAvailable = true;
  bool _goDown = true;

  Future<void> _getBlogs() async {
    setState(() {
      _loadingBlogs = true;
    });

    QuerySnapshot querySnapshot =
        await widget.query.limit(widget.perPage).get();
    _blogs = querySnapshot.docs;
    if (_blogs.isEmpty) {
      setState(() {
        _loadingBlogs = false;
      });
      return;
    }
    _lastDoc = querySnapshot.docs[querySnapshot.docs.length - 1];
    setState(() {
      _loadingBlogs = false;
    });
  }

  void _getMoreBlogs() async {
    if (!_moreBlogsAvailable) {
      return;
    }

    if (_gettingMoreBlogs) {
      return;
    }

    setState(() {
      _gettingMoreBlogs = true;
    });

    QuerySnapshot querySnapshot = await widget.query
        .startAfter([_lastDoc.get('date')])
        .limit(widget.perPage)
        .get();
    if (querySnapshot.docs.length < widget.perPage) {
      _moreBlogsAvailable = false;
    }

    _lastDoc = querySnapshot.docs[querySnapshot.docs.length - 1];
    _blogs.addAll(querySnapshot.docs);
    setState(() {
      _gettingMoreBlogs = false;
    });
  }

  Padding getCard(int index) {
    const double leftPadding = 12.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            onLongPress: widget.isEditable
                ? () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EditBlog(
                        curTitle: _blogs[index].get('title'),
                        curText: _blogs[index].get('text'),
                        blogId: _blogs[index].id)))
                : null,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    ViewBlogScreen(blogId: _blogs[index].id))),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FutureBuilder(
                        future: _db
                            .collection('profiles')
                            .doc(_blogs[index].get('uuid'))
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
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
                                  backgroundImage: NetworkImage(
                                      snapshot.data!.get('avatar')),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: leftPadding),
                                  child: Text(snapshot.data!.get('name')),
                                )
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    Text(
                      _formatter.format(_blogs[index].get("date").toDate()),
                      style: const TextStyle(
                          fontWeight: FontWeight.w200, fontSize: 12),
                    )
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                Row(
                  children: [
                    Text(_blogs[index].get("title"),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(bottom: 8))
              ],
            ),
            subtitle: Text((_blogs[index].get("text") as String)
                .characters
                .take(400)
                .toString()),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    initializeDateFormatting("ru_RU");
    _formatter = DateFormat('dd MMM yyyy в HH:mm', "ru_RU");
    _getBlogs();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _goDown = true;
        });
      } else {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          setState(() {
            _goDown = false;
          });
        }
      }

      if (maxScroll - currentScroll <= delta) {
        _getMoreBlogs();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loadingBlogs
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  _getBlogs();
                },
                child: _blogs.isEmpty
                    ? ListView(children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Пусто"),
                            ],
                          ),
                        ),
                      ])
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _blogs.length, // _gettingMoreBlogs ? _blogs.length + 1 : _blogs.length
                        itemBuilder: (context, index) {
                          // if (index < _blogs.length) {
                          //   return getCard(index);
                          // } else {
                          //   return const Padding(
                          //     padding: EdgeInsets.only(top: 20, bottom: 30),
                          //     child:
                          //         Center(child: CircularProgressIndicator()),
                          //   );
                          // }
                          return getCard(index);
                        }),
              ),
              _goDown
                  ? const SizedBox.shrink()
                  : Positioned(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: FilledButton(
                                  style: FilledButton.styleFrom(
                                      shape: const CircleBorder()),
                                  onPressed: () async {
                                    setState(() {
                                      _goDown = true;
                                    });
                                    SchedulerBinding.instance
                                        .addPostFrameCallback((_) {
                                      _scrollController.animateTo(
                                          _scrollController
                                              .position.minScrollExtent,
                                          duration:
                                              const Duration(milliseconds: 400),
                                          curve: Curves.fastOutSlowIn);
                                    });
                                  },
                                  child: const Icon(Icons.arrow_upward)),
                            ),
                          ],
                        ),
                      ],
                    ))
            ],
          );
  }
}
