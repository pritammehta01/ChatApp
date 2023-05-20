import 'dart:developer';

import 'package:chat_app/helper/chat_user_card.dart';
import 'package:chat_app/helper/models/user_model.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/helper/api/firebase_references.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //for storing all users
  List<ChatUser> _list = [];
  //for searched items
  List<ChatUser> _searchingList = [];
  //for starting search status
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    Helper.getSelfInfo();
    //for setting user status to active
    Helper.updateActiveStatus(true);

    // for updating user active status acording to lifecycle events
    //resume -- active or online
    // pause -- inactive or ofline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');
      if (Helper.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          Helper.updateActiveStatus(true);
        }

        if (message.toString().contains('pause')) {
          Helper.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(
              Icons.home,
              color: Colors.black,
            ),
            title: _isSearching
                ? TextField(
                    style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
                    decoration: const InputDecoration(
                        hintText: "Name,Number",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search)),
                    autofocus: true,
                    onChanged: (value) {
                      _searchingList.clear();
                      for (var i in _list) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.phone
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchingList.add(i);
                        }
                        setState(() {
                          _searchingList;
                        });
                      }
                    },
                  )
                : const Text("ChatApp"),
            centerTitle: true,
            actions: [
              //search user button
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(
                    _isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search,
                    color: Colors.black,
                  )),
              //more feature button
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: Helper.me)));
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  )),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            child: StreamBuilder(
              stream: Helper.getAllUser(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _list = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];

                    if (_list.isNotEmpty) {
                      return ListView.builder(
                        itemCount:
                            _isSearching ? _searchingList.length : _list.length,
                        itemBuilder: (context, index) {
                          return ChatUserCard(
                              user: _isSearching
                                  ? _searchingList[index]
                                  : _list[index]);
                        },
                      );
                    } else {
                      return const Center(
                          child: Text(
                        "No Connection Found",
                        style: TextStyle(fontSize: 20),
                      ));
                    }
                }
              },
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Helper.auth.signOut().then((value) {
          //       Navigator.pushReplacement(context,
          //           MaterialPageRoute(builder: (_) => const LoginScreen()));
          //     });
          //     //  Navigator.push(context,
          //     //       MaterialPageRoute(builder: (context) => PorofileScreen()));
          //   },
          //   child: const Icon(Icons.remove),
          // ),
        ),
      ),
    );
  }
}
