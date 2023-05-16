import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(content)),
  );
}

Future<File?> pickImage(BuildContext context) async {
  File? image;
  try {
    final imageSource = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("select Image Source"),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text("Camera"),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text("Gallery"),
                )
              ],
            ));
    if (imageSource != null) {
      final pickedImage = await ImagePicker().pickImage(source: imageSource);
      image = File(pickedImage!.path);
    }
  } catch (e) {
    showSnackBar(context, e.toString());
  }
  return image;
}
