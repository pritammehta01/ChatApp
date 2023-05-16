import 'package:chat_app/helper/api/splash_Service.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScrrenState();
}

class _SplashScrrenState extends State<SplashScreen> {
  SplashSrevice splashScreen = SplashSrevice();
  @override
  void initState() {
    super.initState();
    splashScreen.signIn(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 30),
                child: Image.asset("assets/chat.png"),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Chat App",
                style: TextStyle(fontSize: 24),
              )
            ],
          )),
    );
  }
}
