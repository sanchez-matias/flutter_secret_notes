import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter_secret_notes/config/plugins/path_builder.dart';

class ImagesPlugin {
  static final picker = ImagePicker();

  static Future<String> pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return '';

    return await _saveImage(pickedFile.path);
  }

  static Future<String> pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return '';

    return await _saveImage(pickedFile.path);
  }

  static Future<String> _saveImage(String imagePath) async {
    final File tempImage = File(imagePath);
    final savedImagePath = await PathBuilder.buildPath(folderName: 'images_storage', fileName: '${DateTime.now()}.jpg');

    final savedImage = await tempImage.copy(savedImagePath);

    // print('Image Saved in: ${savedImage.path}');
    return savedImage.path;
  }

  static Future<void> deleteImage(String path) async {
    final file = File(path);

    if (await file.exists()) {
      file.delete();
    }
  }
}
