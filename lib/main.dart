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
  bool dark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // アプリ名
      title: 'ChatApp',
      theme: dark ? ThemeData.dark() : ThemeData.light(),
      darkTheme: ThemeData.dark(),
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

                      final uid = auth.currentUser?.uid.toString();
                      await FirebaseFirestore.instance
                          .collection('users') // コレクションID指定
                          .doc(uid) // ドキュメントID自動生成
                          .set({
                        'name': 'John',
                        'createTime': FieldValue.serverTimestamp(),
                        'updateTime': FieldValue.serverTimestamp()
                      });

                      // ログインに成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
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
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                // ログイン登録ボタン
                child: OutlinedButton(
                  child: const Text('匿名ログイン'),
                  onPressed: () async {
                    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                    try {
                      final result = await firebaseAuth.signInAnonymously();
                      final auth = FirebaseAuth.instance;
                      final uid = auth.currentUser?.uid.toString();

                      await FirebaseFirestore.instance
                          .collection('users') // コレクションID指定
                          .doc(uid) // ドキュメントID自動生成
                          .set({
                        'name': 'John',
                        'createTime': FieldValue.serverTimestamp(),
                        'updateTime': FieldValue.serverTimestamp()
                      });

                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => ChatPage(result.user!),
                      ));
                    } catch (e) {
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('エラー'),
                              content: Text(e.toString()),
                            );
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
        title: const Text('GALLERY'),
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
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 414),
              child: Column(
                children: [
                  // Container(
                  //   padding: EdgeInsets.all(8),
                  //   child: Text('ログイン情報：${user.email}'),
                  // ),
                  Expanded(
                    // FutureBuilder
                    // 非同期処理の結果を元にWidgetを作れる
                    child: StreamBuilder<QuerySnapshot>(
                      // 投稿メッセージ一覧を取得（非同期処理）
                      // 投稿日時でソート
                      stream: FirebaseFirestore.instance
                          .collectionGroup('post')
                          .snapshots(),
                      builder: (context, snapshot) {
                        print(snapshot);
                        // データが取得できた場合
                        if (snapshot.hasData) {
                          final List<DocumentSnapshot> documents =
                              snapshot.data!.docs;
                          // 取得した投稿メッセージ一覧を元にリスト表示
                          return ListView(
                            children: documents.map((document) {
                              print(document);
                              return Card(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(document['text']),
                                      // 自分の投稿メッセージの場合は削除ボタンを表示
                                      trailing: document['email'] == user.email
                                          ? IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () async {
                                                final FirebaseAuth auth =
                                                    FirebaseAuth.instance;
                                                final uid = auth
                                                    .currentUser?.uid
                                                    .toString();
                                                // 投稿メッセージのドキュメントを削除
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(uid)
                                                    .collection('post')
                                                    .doc(document.id)
                                                    .delete();
                                              },
                                            )
                                          : IconButton(
                                              icon: Icon(Icons.eight_k_plus),
                                              onPressed: () async {
                                                final FirebaseAuth auth =
                                                    FirebaseAuth.instance;
                                                final uid = auth
                                                    .currentUser?.uid
                                                    .toString();
                                                final userRef =
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(uid);
                                                var followedUserRef =
                                                    document['author']
                                                        .replaceAll(
                                                            "users/", "");
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(uid)
                                                    .collection('followUsers')
                                                    .doc(followedUserRef)
                                                    .set({
                                                  'id': followedUserRef,
                                                  'userRef': document['author'],
                                                  'createTime': FieldValue
                                                      .serverTimestamp()
                                                });
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(followedUserRef)
                                                    .collection('followedUsers')
                                                    .doc(uid)
                                                    .set({
                                                  'id': uid,
                                                  'userRef': userRef.path,
                                                  'createTime': FieldValue
                                                      .serverTimestamp()
                                                });
                                              },
                                            ),
                                    ),
                                    Container(
                                        // width: 154,
                                        // height: 230,
                                        child: Image.network(
                                      document['imageUrl'],
                                      fit: BoxFit.contain,
                                    )),
                                    ListTile(title: Text(document['email'])),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }
                        // データが読込中の場合
                        return Center(
                          child: Text('読込中...'),
                        );
                      },
                    ),
                  ),
                ],
              ))),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Color.fromARGB(255, 255, 255, 255),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business, color: Colors.white),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school, color: Colors.white),
            label: 'School',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.white),
            label: 'Settings',
          ),
        ],
        //  currentIndex: _selectedIndex,
        //  selectedItemColor: Colors.amber[800],
        //  onTap: _onItemTapped,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(onPressed: () {}),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () async {
                  // 投稿画面に遷移
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return AddPostPage(user);
                    }),
                  );
                },
              ),
              SizedBox(width: 20),
              FloatingActionButton(
                onPressed: () async {
                  // 投稿画面に遷移
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return AddPostPage1(user);
                    }),
                  );
                },
              ),
              SizedBox(width: 20),
              FloatingActionButton(onPressed: () {}),
            ],
          ),
          SizedBox(height: 20),
          FloatingActionButton(onPressed: () {}),
        ],
      ),
    );
  }
}

// 投稿画面用Widget
class AddPostPage1 extends StatefulWidget {
  // 引数からユーザー情報を受け取る
  AddPostPage1(this.user);
  // ユーザー情報
  final User user;

  @override
  _AddPostPageState1 createState() => _AddPostPageState1();
}

class _AddPostPageState1 extends State<AddPostPage1> {
  // 作成したドキュメント一覧
  List<DocumentSnapshot> documentList = [];
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid.toString();
    return Scaffold(
        body: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
          Expanded(
            child: Container(
              height: double.infinity,
              alignment: Alignment.topCenter,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('post')
                    .orderBy('createTime')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('エラーが発生しました');
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final list = snapshot.requireData.docs
                      .map<String>((DocumentSnapshot document) {
                    final documentData =
                        document.data()! as Map<String, dynamic>;
                    return documentData['email']! as String;
                  }).toList();

                  final reverseList = list.reversed.toList();
                  return ListView.builder(
                    itemCount: reverseList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Center(
                        child: Text(
                          reverseList[index],
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ])));
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

                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final uid = auth.currentUser?.uid.toString();
                      final userRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('post')
                          .doc()
                          .set({
                        'text': messageText,
                        'email': email,
                        'author': userRef.path,
                        'createTime': date,
                        'updateTime': FieldValue.serverTimestamp(),
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
