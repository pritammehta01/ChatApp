import 'package:chat_app/helper/models/message.dart';
import 'package:chat_app/helper/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class Helper {
//for storing mySelf information
  static late ChatUser me;

  //for athentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for  accessing cloud firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        // log("My data${user.data()}");
      }
    });
  }

  //for return current user
  static User get user => auth.currentUser!;

  //for checking if user exist or not?
  static Future<bool> userExists() async {
    return (await firestore.collection("users").doc(user.uid).get()).exists;
  }

  //for getting all user from fierstore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return firestore
        .collection("users")
        .where("id", isNotEqualTo: user.uid)
        .snapshots();
  }

  //for updating user information
  static Future<void> updateUesrInfo() async {
    await firestore.collection("users").doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateUesrProfile() async {
    await firestore
        .collection("users")
        .doc(user.uid)
        .update({'image': me.image});
  }

  //usful for getting convertion Id
  static getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  ///*---------------Chat Screen Related APIs---------*
  // for getting all messages of specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
      ChatUser user) {
    return firestore
        .collection('chat/${getConversationID(user.id)}/messages/')
        .snapshots();
  }

  //for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    //message sending time(also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        msg: msg,
        toId: chatUser.id,
        read: '',
        type: Type.text,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chat/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chat/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chat/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }
}
