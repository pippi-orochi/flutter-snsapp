// ignore: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile? _image;
  final imagePicker = ImagePicker();

  // カメラから画像を取得するメソッド
  Future getImageFromCamera() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = XFile(pickedFile.path);
      }
    });
  }

  // ギャラリーから画像を取得するメソッド
  Future getImageFromGarally() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    // Image.network(pickedFile!.path);
    setState(() {
      if (pickedFile != null) {
        _image = XFile(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            // 取得した画像を表示(ない場合はメッセージ)
            child: _image == null
                ? Text(
                    '写真を選択してください',
                    style: Theme.of(context).textTheme.headline4,
                  )
                : Image.network(
                    'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png',
                    width: 128,
                    height: 128,
                  )),
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          // カメラから取得するボタン
          FloatingActionButton(
              onPressed: getImageFromCamera,
              child: const Icon(Icons.photo_camera)),
          // ギャラリーから取得するボタン
          FloatingActionButton(
              onPressed: getImageFromGarally,
              child: const Icon(Icons.photo_album))
        ]));
  }
}
