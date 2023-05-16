import 'dart:async';
import 'package:chat_app/helper/api/firebase_references.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashSrevice {
  void signIn(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white, statusBarColor: Colors.white));
    final auth = Helper.auth.currentUser;
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                auth != null ? const HomeScreen() : const LoginScreen()),
      );
    });
  }
}
