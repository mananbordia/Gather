import 'dart:io';

import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UploadMultipleImage extends StatefulWidget {
  UploadMultipleImage() : super();
  final String title = "Firebase Storage";

  @override
  UploadMultipleImageState createState() => UploadMultipleImageState();
}

class UploadMultipleImageState extends State<UploadMultipleImage> {
  String _path;
  Map<String, String> _paths;
  String _extension;
  FileType _pickType;
  bool _multiPick = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];
  TextEditingController fileNameTextEditingController = TextEditingController();
//  bool isFileSelected = false;
//  bool _validFileName = true;
//  bool uploading = false;

  dropDown() {
    return DropdownButton(
      isExpanded: true,
      hint: Text('Select'),
      value: _pickType,
      items: <DropdownMenuItem>[
        DropdownMenuItem(
          child: Text('Audio'),
          value: FileType.audio,
        ),
        DropdownMenuItem(
          child: Text('Image'),
          value: FileType.image,
        ),
        DropdownMenuItem(
          child: Text('Video'),
          value: FileType.video,
        ),
        DropdownMenuItem(
          child: Text('Any'),
          value: FileType.any,
        ),
        DropdownMenuItem(
          child: Text('Custom'),
          value: FileType.custom,
        ),
      ],
      onChanged: (value) {
        setState(() {
          _pickType = value;
        });
        print("Test $_pickType");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                dropDown(),
                SwitchListTile.adaptive(
                  title: Text(
                    "Pick Multiple Files",
                    textAlign: TextAlign.left,
                  ),
                  value: _multiPick,
                  onChanged: (bool value) {
                    setState(() {
                      _multiPick = value;
                    });
                  },
                ),
                OutlineButton(
                  child: Text('Open File Explorer'),
                  onPressed: openFileExplorer,
                )
              ],
            )),
      ),
    );
  }

  openFileExplorer() async {
    try {
      _path = null;
      if (_multiPick) {
        _paths = await FilePicker.getMultiFilePath(
          type: _pickType,
        );
      } else {
        _path = await FilePicker.getFilePath(type: _pickType);
//        if (_path != null)
//          setState(() {
//            isFileSelected = true;
//          });
      }
      if (!mounted) {
        return;
      }
      uploadToFirebase();
    } on PlatformException catch (e) {
      print("Unsupported Operation " + e.toString());
    }
  }

  uploadToFirebase() {
    if (_multiPick) {
      _paths.forEach((fileName, filePath) {
        upload(fileName, filePath);
      });
    } else {
//      String fileName = fileNameTextEditingController.text + '.$_extension';
      String fileName = _path.toString().split('/').last;
      print("###################Test ##################$fileName");
      String filePath = _path;
      upload(fileName, filePath);
    }
  }

  upload(fileName, filePath) async {
//    setState(() {
//      uploading = true;
//    });
    _extension = fileName.toString().split(".").last;
    StorageUploadTask uploadTask = testStorageReference.child(fileName).putFile(
        File(filePath),
        StorageMetadata(
          contentType: '${_pickType.toString().split('.').last}/$_extension',
        ));

    StorageTaskSnapshot mStorageTaskSnapshot = await uploadTask.onComplete;
    String mDownloadUrl = await mStorageTaskSnapshot.ref.getDownloadURL();
    print("$mDownloadUrl");

    setState(() {
      _tasks.add(uploadTask);
    });

//    removeCache();
  }

//  setFileName() {
//    if (fileNameTextEditingController.text.isNotEmpty &&
//        fileNameTextEditingController.text.length < 10) {
//      setState(() {
//        isFileSelected = false;
//        _validFileName = true;
//      });
//      uploadToFirebase();
//    } else
//      setState(() {
//        _validFileName = false;
//      });
//  }

//  removeCache() {
//    setState(() {
//      _validFileName = true;
//      fileNameTextEditingController.clear();
//      isFileSelected = false;
//      uploading = false;
//    });
//  }

//  getFileNameScreen() {
//    return Scaffold(
//      appBar: AppBar(
//        backgroundColor: Colors.black,
//        leading: IconButton(
//          icon: Icon(Icons.arrow_back, color: Colors.white),
//          onPressed: removeCache,
//        ),
//        title: Text(
//          "New Post",
//          style: TextStyle(
//              fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold),
//        ),
//        actions: <Widget>[
//          FlatButton(
//            onPressed: uploading ? null : setFileName,
//            child: Text(
//              "Share",
//              style: TextStyle(
//                  color: Colors.green,
//                  fontWeight: FontWeight.bold,
//                  fontSize: 16.0),
//            ),
//          )
//        ],
//      ),
//      backgroundColor: Colors.black,
//      body: ListView(
//        children: <Widget>[
//          uploading ? linearProgress() : Text(""),
//          Container(
//            height: 230.0,
//            width: MediaQuery.of(context).size.width * 0.8,
//            child: Center(
//              child: AspectRatio(
//                aspectRatio: 16 / 9,
//                child: Container(
//                  decoration: BoxDecoration(
//                    image: DecorationImage(
//                        image: FileImage(file, fit: BoxFit.cover),
//                  ),
//                ),
//              ),
//            ),
//          ),
//          Padding(
//            padding: EdgeInsets.only(top: 12.0),
//          ),
//          ListTile(
//            title: Container(
//              width: 250.0,
//              child: TextField(
//                style: TextStyle(color: Colors.white),
//                controller: fileNameTextEditingController,
//                decoration: InputDecoration(
//                    hintText: "Write your file name",
//                    hintStyle: TextStyle(color: Colors.white),
//                    border: InputBorder.none,
//                    errorText:
//                        _validFileName ? null : "Profile name is very short"),
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
//  }
}
