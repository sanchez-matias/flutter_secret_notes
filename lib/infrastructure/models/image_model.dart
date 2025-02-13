import 'package:flutter_secret_notes/domain/entities/image.dart';

class CustomImageModel extends CustomImage {
  CustomImageModel({required super.id, required super.path});

  factory CustomImageModel.fromJson(Map<String, dynamic> json) => CustomImageModel(
        id: json['ImageID'],
        path: json['ImagePath'],
      );
}
