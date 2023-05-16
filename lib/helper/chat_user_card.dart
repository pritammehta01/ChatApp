// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chat_app/helper/api/firebase_references.dart';
import 'package:chat_app/helper/models/message.dart';
import 'package:chat_app/helper/my_date_utils.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/helper/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info(if null --> no message)
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      //color: Colors.orange,
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black26)),
      //margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: InkWell(
          //for navigating ChatScreen
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ChatScreen(
                        user: widget.user,
                      ))),
          child: StreamBuilder(
            stream: Helper.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    width: 50,
                    height: 50,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle: Text(
                  _message != null ? _message!.msg : widget.user.about,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                trailing: _message == null
                    ? null //show nothing when no message sent
                    : _message!.read.isEmpty &&
                            _message!.fromId != Helper.user.uid
                        ?
                        //show for unread message
                        Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.green),
                          )
                        :
                        //message sent time
                        Text(MyDateUtil.getLastMessageTime(
                            context: context, time: _message!.sent)),
              );
            },
          )),
    );
  }
}
