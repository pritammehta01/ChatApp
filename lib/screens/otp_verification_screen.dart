import 'package:chat_app/helper/api/firebase_references.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/Widgets/custom_button.dart';
import 'package:chat_app/Widgets/utils.dart';
import 'package:chat_app/screens/user_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpVerificationScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final verificationId;

  const OtpVerificationScreen({super.key, required this.verificationId});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerivicationState();
}

class _OtpVerivicationState extends State<OtpVerificationScreen> {
  bool loading = false;
  String? otp;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Pinput(
                    length: 6,
                    onCompleted: (value) {
                      otp = value;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                      title: "Verify",
                      loading: loading,
                      onTap: () async {
                        setState(() {
                          loading = true;
                        });
                        final credential = PhoneAuthProvider.credential(
                            verificationId: widget.verificationId,
                            smsCode: otp.toString());
                        try {
                          await Helper.auth.signInWithCredential(credential);

                          if ((await Helper.userExists())) {
                            //existing user
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HomeScreen()));
                            setState(() {
                              loading = false;
                            });
                          } else {
                            //new user
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const UserdetailsScreen()));
                            setState(() {
                              loading = false;
                            });
                          }
                        } catch (e) {
                          showSnackBar(context, e.toString());
                          setState(() {
                            loading = false;
                          });
                        }
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (route) => false);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Phone Number")),
                ],
              ),
            ],
          )),
    );
  }
}
