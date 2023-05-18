// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/api/firebase_references.dart';
import 'package:chat_app/helper/my_date_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/helper/models/message.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<MessageCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Helper.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

// sender or another user message
  Widget _blueMessage() {
    //update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      Helper.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightBlue),
                color: const Color.fromARGB(255, 221, 245, 255),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: widget.message.type == Type.text
                ?
                //show text
                Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 16),
                  )
                :
                //show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      fit: BoxFit.fill,
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 60,
                      ),
                    )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(MyDateUtil.getFormattedTime(
              context: context, time: widget.message.sent)),
        )
      ],
    );
  }

//our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 5,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_outlined,
                color: Colors.blue,
              ),
            const SizedBox(
              width: 5,
            ),
            Text(MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent)),
          ],
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightGreen),
                color: const Color.fromARGB(255, 221, 255, 156),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: widget.message.type == Type.text
                ?
                //show text
                Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 16),
                  )
                :
                //show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      fit: BoxFit.fill,
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 60,
                      ),
                    )),
          ),
        ),
      ],
    );
    ;
  }
}
