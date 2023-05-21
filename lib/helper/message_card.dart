// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Widgets/utils.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/helper/api/firebase_references.dart';
import 'package:chat_app/helper/models/message.dart';
import 'package:chat_app/helper/my_date_utils.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

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
    bool isMe = Helper.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
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
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (_) {
          return ListView(shrinkWrap: true, children: [
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 150, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
            widget.message.type == Type.text
                ? _OptionItem(
                    icon: const Icon(
                      Icons.copy_all_outlined,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: "Copy Text",
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        Navigator.pop(context);
                        showSnackBar(context, "Text copied");
                      });
                    })
                : _OptionItem(
                    icon: const Icon(
                      Icons.download,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: "Save Image",
                    onTap: () async {
                      try {
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: "Chat App")
                            .then((success) {
                          Navigator.pop(context);
                          if (success != null) {
                            showSnackBar(context, "Image Saved");
                          }
                        });
                      } catch (e) {
                        log('ErroWhileSavingImage :$e');
                      }
                    }),
            if (isMe)
              const Divider(
                endIndent: 10,
                indent: 10,
                color: Colors.black54,
              ),
            if (widget.message.type == Type.text && isMe)
              _OptionItem(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 26,
                  ),
                  name: "Edit Message",
                  onTap: () {
                    Navigator.pop(context);
                    _showMessageUpdateDialog();
                  }),
            if (isMe)
              _OptionItem(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 26,
                  ),
                  name: "Delete Message",
                  onTap: () async {
                    await Helper.deleteMessage(widget.message)
                        .then((value) => Navigator.pop(context));
                  }),
            const Divider(
              endIndent: 10,
              indent: 10,
              color: Colors.black54,
            ),
            _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: Colors.blue,
                  size: 26,
                ),
                name:
                    "Sent At ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}",
                onTap: () {}),
            _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: Colors.green,
                  size: 26,
                ),
                name: widget.message.sent.isEmpty
                    ? "Read At : Not seen yet"
                    : "Read At ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}",
                onTap: () {}),
          ]);
        });
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  top: 20, left: 24, right: 24, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 24,
                  ),
                  Text(" Update Message"),
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                initialValue: updatedMsg,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                //cancel button
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                //update button
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Helper.updateMessage(widget.message, updatedMsg);
                  },
                  child: const Text(
                    "Update",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                )
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 20, bottom: 25),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              "  $name",
              style: const TextStyle(letterSpacing: 2),
            ))
          ],
        ),
      ),
    );
  }
}
