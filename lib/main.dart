// ignore: unused_import
// ignore_for_file: unused_import, depend_on_referenced_packages
import 'dart:convert';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

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
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // アプリ名
      title: 'ChatApp',
      theme: ThemeData(
        // テーマカラー
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'NotoSansCJKJp',
      ),
      // ログイン画面を表示
      home: LoginPage(),
    );
  }
}

// ログイン画面用Widget
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // メッセージ表示用
  String infoText = '';
  // 入力したメールアドレス・パスワード
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // メールアドレス入力
              TextFormField(
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              // パスワード入力
              TextFormField(
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              Container(
                padding: const EdgeInsets.all(8),
                // メッセージ表示
                child: Text(infoText),
              ),
              Container(
                width: double.infinity,
                // ユーザー登録ボタン
                child: ElevatedButton(
                  child: const Text('ユーザー登録'),
                  onPressed: () async {
                    try {
                      // メール/パスワードでユーザー登録
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // ユーザー登録に成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return ChatPage(result.user!);
                        }),
                      );
                    } catch (e) {
                      // ユーザー登録に失敗した場合
                      setState(() {
                        infoText = "登録に失敗しました：${e.toString()}";
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                // ログイン登録ボタン
                child: OutlinedButton(
                  child: const Text('ログイン'),
                  onPressed: () async {
                    try {
                      // メール/パスワードでログイン
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // ログインに成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          print(result.user);
                          return ChatPage(result.user!);
                        }),
                      );
                    } catch (e) {
                      // ログインに失敗した場合
                      setState(() {
                        infoText = "ログインに失敗しました：${e.toString()}";
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// チャット画面用Widget
class ChatPage extends StatelessWidget {
  // 引数からユーザー情報を受け取れるようにする
  ChatPage(this.user);
  // ユーザー情報
  final User user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャット'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // ログアウト処理
              // 内部で保持しているログイン情報等が初期化される
              // （現時点ではログアウト時はこの処理を呼び出せばOKと、思うぐらいで大丈夫です）
              await FirebaseAuth.instance.signOut();
              // ログイン画面に遷移＋チャット画面を破棄
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fitHeight,
              image: AssetImage('images/sample.jpg'),
            ),
          ),
        ),
      ),
    );
  }
}

// 投稿画面用Widget
class AddPostPage extends StatefulWidget {
  // 引数からユーザー情報を受け取る
  AddPostPage(this.user);
  // ユーザー情報
  final User user;
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  // 入力した投稿メッセージ
  String messageText = '';
  String url = '';

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
    final pickerFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    var bytes = await pickerFile?.readAsBytes();
    File file = File(pickerFile!.path);
    FirebaseStorage storage = FirebaseStorage.instance;
    var fileName = basename(file.path);
    final storedImage = await storage.ref("UL/$fileName").putData(bytes!);
    var dowurl = await storedImage.ref.getDownloadURL();
    var value = dowurl.toString();

    // print(pickedFile);
    // Image.network(pickedFile!.path);
    setState(() {
      url = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('チャット投稿'),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 投稿メッセージ入力
                TextFormField(
                  decoration: const InputDecoration(labelText: '投稿メッセージ'),
                  // 複数行のテキスト入力
                  keyboardType: TextInputType.multiline,
                  // 最大3行
                  maxLines: 3,
                  onChanged: (String value) {
                    setState(() {
                      messageText = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text('投稿'),
                    onPressed: () async {
                      final date =
                          DateTime.now().toLocal().toIso8601String(); // 現在の日時
                      final email = widget.user.email; // AddPostPage のデータを参照
                      // 投稿メッセージ用ドキュメント作成
                      await FirebaseFirestore.instance
                          .collection('posts') // コレクションID指定
                          .doc() // ドキュメントID自動生成
                          .set({
                        'text': messageText,
                        'email': email,
                        'date': date,
                        'imageUrl': url
                      });
                      // 1つ前の画面に戻る
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: _image == null
                      ? Text(
                          '写真を選択してください',
                          // ignore: deprecated_member_use
                          style: Theme.of(context).textTheme.headline4,
                        )
                      : Image.network(_image!.path),
                )
              ],
            ),
          ),
        ),
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          // カメラから取得するボタン
          FloatingActionButton(
              onPressed: getImageFromCamera,
              child: const Icon(Icons.photo_camera)),
          // ギャラリーから取得するボタン
          FloatingActionButton(
              onPressed: getImageFromGarally,
              child: const Icon(Icons.photo_camera)),
        ]));
  }
}
