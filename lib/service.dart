import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class UploadService {
  static const String BASE_URL = "http://192.168.1.103:9999/";

  Future<String> login(String username, String password) async {
    var dio = Dio();
    print("un" + username);
    var response = await dio.post(BASE_URL + "login",
        data: {'username': username, 'password': password});

    var result = response.data;
    print(result['jwt']);
    return result['jwt'];
  }

  Future<String> uploadFile(
      String token, String filePath, String fileName) async {
    var dio = Dio();
    var postData = FormData.fromMap(
        {"file": await MultipartFile.fromFile(filePath, filename: fileName)});
    var option = Options(
        method: "POST",
        contentType: "multipart/form-data",
        headers: {'Authorization': 'Bearer ' + token});
    var res = await dio.post(
      BASE_URL + "upload",
      data: postData,
      options: option,
    );
    print(res.data['content']);
    return res.data['content'];
  }

  Future<FileInfo> openFilePicker() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    PlatformFile file;

    if (result != null) {
      file = result.files.first;
    }

    print("path" + file.path);
    return FileInfo(file.path, file.name);
  }
}

class FileInfo {
  String path;
  String name;
  FileInfo(this.path, this.name);
}
