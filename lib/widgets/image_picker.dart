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

  Future<void> _pickedImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
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

  void _showImageSource() {
    showBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickedImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.browse_gallery),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickedImage(ImageSource.gallery);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _showImageSource();
          },
          child: CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey,
            backgroundImage:
                _pickedImageFile != null
                    ? FileImage(File(_pickedImageFile!.path))
                    : null,
          ),
        ),
        IconButton(onPressed: _showImageSource, icon: Icon(Icons.camera_alt)),
        Text('Add a photo'),
      ],
    );
  }
}
