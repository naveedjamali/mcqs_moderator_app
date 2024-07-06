import 'dart:io';

import 'package:path_provider/path_provider.dart';

class JsonFileIo{


  Future<String> get _localPath async{
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<File> writeJson(String fileName, String json)async{
    final file = await _localFile(fileName);
    return file.writeAsString(json);
  }
}