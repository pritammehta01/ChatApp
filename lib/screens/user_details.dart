import 'dart:io';

import 'package:chat_app/Widgets/custom_button.dart';
import 'package:chat_app/Widgets/utils.dart';
import 'package:chat_app/helper/api/firebase_references.dart';
import 'package:chat_app/helper/models/user_model.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UserdetailsScreen extends StatefulWidget {
  const UserdetailsScreen({super.key});

  @override
  State<UserdetailsScreen> createState() => _PorofileScreenState();
}

class _PorofileScreenState extends State<UserdetailsScreen> {
  File? image;
  //firestorage
  final FirebaseStorage storage = FirebaseStorage.instance;

  //cloud firestore instance
  final firestore = Helper.firestore;
  final user = Helper.user;
  bool loading = false;

  final aboutcontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final namecontroller = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    namecontroller.dispose();
    emailcontroller.dispose();
    aboutcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    selectImage();
                  },
                  child: Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: image != null
                        ? CircleAvatar(
                            backgroundImage: FileImage(image!),
                            child: const Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.orange,
                                size: 40,
                              ),
                            ),
                          )
                        : const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.grey,
                              size: 160,
                            ),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: namecontroller,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      hintText: "Name",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailcontroller,
                  decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                ),
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: aboutcontroller,
                  decoration: InputDecoration(
                      hintText: "About",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomButton(
                    title: "Next",
                    loading: loading,
                    onTap: () {
                      setState(() {
                        loading = true;
                      });
                      createUser().then((value) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()));
                        setState(() {
                          loading = false;
                        });
                      }).onError((e, stackTrace) {
                        showSnackBar(context, e.toString());
                        setState(() {
                          loading = false;
                        });
                      });
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  void selectImage() async {
    image = await pickImage(context);
    // ignore: unused_local_variable
    final imageUrl = await uploadImage(image!);
    setState(() {});
  }

  Future createUser() async {
    final imageUrl = await uploadImage(image!);
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        isOnline: false,
        image: imageUrl,
        phone: user.phoneNumber!,
        about: aboutcontroller.text.toString(),
        name: namecontroller.text.toString(),
        createdAt: time,
        lastActive: time,
        id: user.uid,
        email: emailcontroller.text.toString(),
        pushToken: "");
    return await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  Future<String> uploadImage(File file) async {
    final Reference ref =
        storage.ref().child("image/${DateTime.now().toString()}");
    final UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot taskSnapshot = await uploadTask;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
