import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/models/user_model.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SizedBox(
        height: 300,
        width: 300,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(130),
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    width: 210,
                    height: 210,
                    imageUrl: user.image,
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  )),
            ),
            Positioned(
              top: 5,
              right: 0,
              child: MaterialButton(
                minWidth: 0,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewProfileScreen(user: user)));
                },
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.blue,
                  size: 35,
                ),
              ),
            ),
            Positioned(
              left: 15,
              top: 10,
              width: 180,
              child: Text(
                user.name,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
