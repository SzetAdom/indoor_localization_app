import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class DataController extends ChangeNotifier {
  ///This controller can save user selected file to save to the apps folder
  ///On the main screen it will show the list of files saved by the user
  ///The user can select a file to load the map
  ///The user can also delete a file
  ///The user can also rename a file
  ///The user can also create a new file

  ///Let user pick a file and copy it to the apps folder
  ///
  ///

  Future<File?> selectFile() async {
    var filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (filePickerResult == null) return null;

    File file = File(filePickerResult.files.first.path!);

    return file;
  }

  Future<bool> fileExists(String fileName) async {
    var appDir = await getApplicationDocumentsDirectory();
    var newFile = File('${appDir.path}/maps/$fileName');
    var res = await newFile.exists();
    return res;
  }

  Future saveFileToStorage(File file) async {
    try {
      var appDir = await getApplicationDocumentsDirectory();
      var newFile = File('${appDir.path}/maps/${file.path.split('/').last}');
      await file.copy(newFile.path);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Valami hiba történt a fájl mentése közben!');
    }
  }

  Future<bool> renameFile(String oldName, String newName) async {
    var appDir = await getApplicationDocumentsDirectory();
    var oldFile = File('${appDir.path}/maps/$oldName.json');
    var newFile = File('${appDir.path}/maps/$newName.json');
    return await oldFile
        .rename(newFile.path)
        .then((value) => true)
        .catchError((e) => false);
  }

  Future deleteFile(String fileName) async {
    var appDir = await getApplicationDocumentsDirectory();
    var newFile = File('${appDir.path}/maps/$fileName.json');
    await newFile.delete();
  }

  List<File> files = [];

  Future<void> loadFiles() async {
    var appDir =
        Directory('${(await getApplicationDocumentsDirectory()).path}/maps');

    if (!await appDir.exists()) {
      await appDir.create();
    }

    var files = await appDir.list().toList();

    this.files = files.map((e) => File(e.path)).toList();
    notifyListeners();
  }
}
