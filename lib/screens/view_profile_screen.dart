import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/helper/models/user_model.dart';

//view profile screen --to view profile of user
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
              )),
          title: Text(
            widget.user.name,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            width: 150,
                            height: 150,
                            imageUrl: widget.user.image,
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                                    child: Icon(CupertinoIcons.person)),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    widget.user.phone,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "About : ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.user.about,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Joined On : ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              MyDateUtil.getLastMessageTime(
                  context: context,
                  time: widget.user.createdAt,
                  showYear: true),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
