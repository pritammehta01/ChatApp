// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onTap;
  const CustomButton({
    Key? key,
    required this.title,
    this.loading = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 40,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.lightBlue),
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.white,
                ))
              : Center(
                  child: Text(
                    title,
                  ),
                ),
        ),
      ),
    );
  }
}
