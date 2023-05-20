// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Widgets/custom_button.dart';
import 'package:chat_app/Widgets/utils.dart';
import 'package:chat_app/helper/api/firebase_references.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/helper/models/user_model.dart';

//profile screen --to show signed in user info
class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = false;
  File? image;
  //firestorage
  final FirebaseStorage storage = FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();
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
          title: const Text(
            "Profile Screen",
            style: TextStyle(fontSize: 18),
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          height: 40,
                          color: Colors.blue,
                          shape: const CircleBorder(),
                          onPressed: () {
                            selectImage();
                          },
                          child: const Icon(
                            Icons.edit_outlined,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          onSaved: (newValue) =>
                              Helper.me.name = newValue ?? widget.user.name,
                          validator: (value) =>
                              value != null && value.isNotEmpty
                                  ? null
                                  : "Required Field",
                          initialValue: widget.user.name,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person),
                              hintText: "Enter Name",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12))),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          onSaved: (newValue) =>
                              Helper.me.about = newValue ?? widget.user.about,
                          validator: (value) =>
                              value != null && value.isNotEmpty
                                  ? null
                                  : "Required Field",
                          initialValue: widget.user.about,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.info),
                              hintText: "About Your Self",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12))),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                  //for updating user information
                  SizedBox(
                    height: 45,
                    width: 200,
                    child: CustomButton(
                        title: "Update",
                        loading: loading,
                        onTap: () async {
                          setState(() {
                            loading = true;
                          });
                          final imageUrl = await uploadImage(image!);
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            await Helper.updateUesrProfile(imageUrl: imageUrl);
                            await Helper.updateUesrInfo().then((value) {
                              showSnackBar(context, "Updated successfully");
                              setState(() {
                                loading = false;
                                // Update the user's image URL in the widget
                                widget.user.image = imageUrl;
                              });
                            });
                          }
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Helper.updateActiveStatus(false);
              await Helper.auth.signOut().then((value) {
                Navigator.pop(context);
                Helper.auth = FirebaseAuth.instance;
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              });
            },
            icon: const Icon(Icons.logout_outlined),
            label: const Text("Log Out")),
      ),
    );
  }

  //for selecting profile image
  void selectImage() async {
    image = await pickImage(context);

    setState(() {});
  }
  //uploading selected image to fierbase storage

  Future<String> uploadImage(File file) async {
    final Reference ref = storage.ref().child("image/${Helper.user.uid}");
    final UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot taskSnapshot = await uploadTask;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
