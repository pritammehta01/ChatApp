// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Widgets/utils.dart';
import 'package:chat_app/helper/api/firebase_references.dart';
import 'package:chat_app/helper/message_card.dart';
import 'package:chat_app/helper/models/message.dart';
import 'package:chat_app/helper/my_date_utils.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
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
  //image
  File? image;
  //for starting value of show emoji or hiding
  bool _showEmoji = false;

  //for storing all messages
  List<Message> _list = [];
  //for handeling message text changes
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
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
                              reverse: true,
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
                _chatInput(),
                //show emojis on keybord on emojibutton click & voice versa
                if (_showEmoji)
                  SizedBox(
                    height: 230,
                    child: EmojiPicker(
                      onBackspacePressed: () => Navigator.pop(context),
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 221, 245, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: Helper.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

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
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
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
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive)
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive),
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ));
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
                      onPressed: () {
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                      )),
                  Expanded(
                      child: TextField(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    controller: _textController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                        hintText: "Type Somthing...", border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () {
                        selectImage();
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                      )),
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
                Helper.sendMessage(
                    widget.user, _textController.text, Type.text);
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

  //for selecting image source from where
  void selectImage() async {
    image = await pickImage(context);
    Helper.sendChatImage(widget.user, image!);

    setState(() {});
  }
}
