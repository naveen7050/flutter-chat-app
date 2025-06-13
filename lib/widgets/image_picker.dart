import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onpicked});

  final void Function(File _pickedImage) onpicked;
  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  void _pickedImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxHeight: 150,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
      });
    }
    widget.onpicked(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _pickedImage();
          },
          child: CircleAvatar(
            radius: 80,
            backgroundColor: Colors.grey,
            backgroundImage:
                _pickedImageFile != null
                    ? FileImage(File(_pickedImageFile!.path))
                    : null,
          ),
        ),
        IconButton(onPressed: _pickedImage, icon: Icon(Icons.camera_alt)),
        Text('Add a photo'),
      ],
    );
  }
}
