import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PathBuilder {
  static Future<String> buildPath({
    required String folderName,
    required String fileName,
  }) async {
    if (!fileName.contains('.')) {
      throw Exception('Incorrect File Name format');
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final String customFolder = '${documentsDirectory.path}${Platform.pathSeparator}$folderName';
    await Directory(customFolder).create(recursive: true); // We make sure that the folder is created
    final String filePath = '$customFolder${Platform.pathSeparator}$fileName';

    return filePath;
  }
}
