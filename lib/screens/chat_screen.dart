// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/api/firebase_references.dart';
import 'package:chat_app/helper/message_card.dart';
import 'package:chat_app/helper/models/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/helper/models/user_model.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];
  //for handeling message text changes
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 221, 245, 255),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: Helper.getAllMessage(widget.user),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const SizedBox();
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;

                      _list = data
                              ?.map((e) => Message.fromJson(e.data()))
                              .toList() ??
                          [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                          itemCount: _list.length,
                          itemBuilder: (context, index) {
                            return MessageCard(
                              message: _list[index],
                            );
                          },
                        );
                      } else {
                        return const Center(
                            child: Text("Say Hii👋",
                                style: TextStyle(fontSize: 20)));
                      }
                  }
                },
              ),
            ),
            _chatInput()
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return Row(
      children: [
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back)),
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: CachedNetworkImage(
            fit: BoxFit.fill,
            width: 45,
            height: 45,
            imageUrl: widget.user.image,
            errorWidget: (context, url, error) =>
                const CircleAvatar(child: Icon(CupertinoIcons.person)),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.user.name,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 2),
            const Text(
              "last Seen unvailable",
              style: TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                      )),
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                        hintText: "Type Somthing...", border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.blueAccent,
                      ))
                ],
              ),
            ),
          ),
          MaterialButton(
            shape: const CircleBorder(),
            padding:
                const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 5),
            color: Colors.teal,
            minWidth: 0,
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                Helper.sendMessage(widget.user, _textController.text);
                _textController.text = '';
              }
            },
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
