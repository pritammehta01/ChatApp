import 'package:chat_app/helper/api/firebase_references.dart';
import 'package:chat_app/screens/otp_verification_screen.dart';
import 'package:chat_app/Widgets/custom_button.dart';
import 'package:chat_app/Widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  // ignore: prefer_typing_uninitialized_variables
  var phonenumber;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
        child: Stack(
          children: [
            Image.asset(
              "assets/chat.png",
              fit: BoxFit.fill,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IntlPhoneField(
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    phonenumber = phone.completeNumber;
                    //print(phonenumber);
                  },
                ),
                CustomButton(
                    title: "Send Verification Code",
                    loading: loading,
                    onTap: () {
                      setState(() {
                        loading = true;
                      });
                      Helper.auth.verifyPhoneNumber(
                        phoneNumber: phonenumber,
                        verificationCompleted: (_) {
                          setState(() {
                            loading = false;
                          });
                        },
                        verificationFailed: (e) {
                          setState(() {
                            loading = false;
                          });
                          showSnackBar(context, e.toString());
                        },
                        codeSent: (verificationId, forceResendingToken) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => OtpVerificationScreen(
                                      verificationId: verificationId)));
                          setState(() {
                            loading = false;
                          });
                        },
                        codeAutoRetrievalTimeout: (verificationId) {},
                      );
                    })
              ],
            ),
          ],
        ),
      ),
    );
  }
}
