import 'package:blog/action_screens/get_user_info.dart';
import 'package:blog/ui_components/blogs_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String displayName;

  Future<void> _navigateAndDisplayName(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GetUserInfoScreen(
              title: 'Изменить имя', buttonText: 'Сохранить'),
        ));
    setState(() {
      displayName = result;
    });
  }

  @override
  void initState() {
    super.initState();

    _auth.userChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          displayName = user.displayName!;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    const int perPage = 10;

    return Center(
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                FutureBuilder(
                    future: db
                        .collection('profiles')
                        .doc(auth.currentUser!.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    NetworkImage(snapshot.data!.get('avatar')),
                              ),
                              const Padding(padding: EdgeInsets.only(top: 10)),
                              Text(
                                displayName,
                                style: const TextStyle(fontSize: 22),
                              )
                            ],
                          ),
                        );
                      }
                    }),
                OutlinedButton(
                  onPressed: () => _navigateAndDisplayName(context),
                  child: const Text('Изменить имя'),
                ),
              ],
            ),
          ),
          const Text(
            "Ваши блоги",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const Divider(),
          Expanded(
              flex: 2,
              child: BlogsList(
                  isEditable: true,
                  perPage: 10,
                  query: db
                      .collection("blogs")
                      .orderBy('date', descending: true)
                      .where('uuid', isEqualTo: auth.currentUser!.uid)
                      .limit(perPage)))
        ],
      ),
    );
  }
}
