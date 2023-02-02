// ignore: unused_import
// ignore_for_file: unused_import
import 'dart:convert';

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
// ignore: unnecessary_import
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_platform/universal_platform.dart';

void main() async {
  // 初期化処理を追加
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBOf4H996p-V_GQJAIJ7JQtYkAYCSA8YC4",
      appId: "1:194151201355:web:449fe229653d2198146bce",
      messagingSenderId: "194151201355",
      projectId: "fir-demo-83f89",
      storageBucket: "gs://fir-demo-83f89.appspot.com",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 3.タイトルとテーマを設定する。画面の本体はMyHomePageで作る。
    return MaterialApp(
      title: "Web: ${UniversalPlatform.isWeb} \n ",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Image? _img;
  Text? _text;

  // ダウンロード処理
  Future<void> _download() async {
    // ファイルのダウンロード
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference imageRef = storage.ref().child("DL").child("flutter.png");
    String imageUrl = await imageRef.getDownloadURL();
    Reference textRef = storage.ref("DL/hello.txt");
    var data = await textRef.getData();

    // 画面に反映
    setState(() {
      _img = Image.network(imageUrl);
      _text = Text(ascii.decode(data!));
    });

    // ローカルにもファイルを書き込み
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File downloadToFile = File("${appDocDir.path}/download-logo.png");
    try {
      await imageRef.writeToFile(downloadToFile);
    } catch (e) {
      print(e);
    }
  }

  // アップロード処理
  void _upload() async {
    // imagePickerで画像を選択する
    final pickerFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    var bytes = await pickerFile?.readAsBytes();
    if (pickerFile == null) {
      return;
    }
    File file = File(pickerFile.path);
    FirebaseStorage storage = FirebaseStorage.instance;
    try {
      await storage.ref("UL/upload-pic.png").putData(bytes!);
      setState(() {
        _img = null;
        _text = const Text("UploadDone");
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // ダウンロードしたイメージとテキストを表示
            children: <Widget>[
              if (_img != null) _img!,
              if (_text != null) _text!,
            ],
          ),
        ),
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          FloatingActionButton(
            onPressed: _download,
            child: const Icon(Icons.download_outlined),
          ),
          FloatingActionButton(
            onPressed: _upload,
            child: const Icon(Icons.upload_outlined),
          ),
        ]));
  }
}
