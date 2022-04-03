import 'dart:ui';
import 'package:box3/screens/FullPicture.dart';
import 'package:box3/screens/box.dart';
import 'package:box3/screens/dev.dart';
import 'package:box3/screens/home2.dart';
import 'package:box3/screens/signin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:box3/screens/GoogleAuthClient.dart';
import 'package:googleapis/classroom/v1.dart';
import 'package:googleapis/cloudasset/v1.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as path;
import 'dart:async';
import 'package:box3/screens/dev.dart';

class MyHomePage extends StatefulWidget {
  final FirebaseUser user;

  MyHomePage(this.user, {Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  drive.FileList list;
  drive.FileList list2;
  drive.FileList list3;
  String newName,
      idBox,
      boxID, //ไอดีของหน้าหลัก
      searchName,
      picName,
      picID,
      picLINK,
      idLast,
      userName,
      folderID,
      folderName,
      folderBoxID,
      folderSearch,
      shareName;
  String nameBox = '';
  String get newPath => _showDialog();
  String get newPath2 => search();
  String get newPath4 => shareBOX();

  @override
  initState() {
    super.initState();
    checkBOX();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$nameBox", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              color: Colors.white,
              onPressed: () {
                search();
              }),
          IconButton(
              icon: Icon(Icons.share),
              color: Colors.white,
              onPressed: () {
                //_share();
                shareBOX();
              }),
        ],
      ),
      drawer: showDrawer(),
      body: Container(
        child: ListView(
          children: generateFilesWidget(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          generateFilesWidget2();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
  
  Drawer showDrawer() => Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(widget.user.photoUrl))),
                ),
                accountName: Text(widget.user.displayName),
                accountEmail: Text(widget.user.email)),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('หน้าหลัก'),
              onTap: () {
                Navigator.pop(context);
                listboxID(boxID);
              },
            ),
            ListTile(
              leading: Icon(Icons.family_restroom),
              title: Text('กล่องของเพื่อน'),
              onTap: () {
                Navigator.pop(context);
                checkAuth3(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('ค้นหา'),
              onTap: () {
                Navigator.pop(context);
                search();
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('แชร์'),
              onTap: () {
                Navigator.pop(context);
                shareBOX();
              },
            ),
            ListTile(
              leading: Icon(Icons.logo_dev),
              title: Text('ผู้พัฒนาแอปพลิเคชัน'),
              onTap: () {
                Navigator.pop(context);
                dev(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('ออกจากระบบ'),
              onTap: () {
                signOut();
              },
            )
          ],
        ),
      );

  Future dev(BuildContext context) async {
    //FirebaseUser user = await _auth.currentUser();
    // if (user != null) {
    //   print("sign-in with google acount");
    //   print('มีหลายกล่อง');
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => MyLoginPage()));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Mydev()));
    // } else if (user == null) {
    //   print("sign-out with google acount");
    //   // Navigator.pushReplacement(
    //   //     context, MaterialPageRoute(builder: (context) => MyLoginPage()));
    // }
  }


  Future checkAuth3(BuildContext context) async {
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      print("sign-in with google acount");
      print('มีหลายกล่อง');
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => MyLoginPage()));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyHomePage2(user)));
    } else if (user == null) {
      print("sign-out with google acount");
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => MyLoginPage()));
    }
  }

  Future checkAuth2(BuildContext context) async {
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      print("sign-in with google acount");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyBox(
                    user,
                    folderID,
                    folderName,
                    folderBoxID,
                    folderSearch,
                  )));
    } else if (user == null) {
      print("sign-out with google acount");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyLoginPage()));
    }
  }

  Future<void> checkBOX() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveFileScope],
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();

    final authHeaders = await user.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    driveApi.files
        .list(
            pageSize: 101,
            supportsAllDrives: false,
            spaces: "drive",
            $fields: "files(id, name, mimeType, thumbnailLink)")
        .then((value) {
      setState(() {
        list2 = value;
      });
      var box = 'notme';
      for (var i = 0; i < list2.files.length; i++) {
        String name = list2.files[i].name;
        switch (name) {
          case "BOX":
            {
              print("Number:${[
                i + 1
              ]} Id: ${list2.files[i].id} File Name:${list2.files[i].name} Type:${list2.files[i].mimeType} ");
              String idBox2 = list2.files[i].id;
              String nameBox2 = list2.files[i].name;
              print('idBox: $idBox');
              print('nameBox: $nameBox');
              setState(() {
                idBox = idBox2;
                nameBox = nameBox2;
                boxID = idBox2;
              });
              print('boxID = $boxID');
              listGoogleDriveFiles2(list2.files[i].name, list2.files[i].id);
              return box = 'me';
            }
            break;
        }
      }
      switch (box) {
        case "notme":
          {
            print("notme");
            createFolderBOX();
            print('สร้างละ');
          }
          break;
      }
    });
  }

  signOut() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    await _auth.signOut();
    await _googleSignIn.signOut();
    checkAuth2(context);
  }

  Future<void> listGoogleDriveFiles(String nameBox, String idBox) async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveFileScope],
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();

    final authHeaders = await user.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    print("idBoxListGoogleDriveFiles() = $idBox");
    print("driveApi=$driveApi");
    driveApi.files
        .list(
            q: '"$idBox" in parents',
            pageSize: null,
            supportsAllDrives: false,
            $fields: "files(id, name, mimeType, thumbnailLink, webViewLink)")
        .then((value) {
      setState(() {
        list = value;
      });
      for (var i = 0; i < list.files.length; i++) {
        print("Number:${[
          i + 1
        ]} Id: ${list.files[i].id} File Name:${list.files[i].name} Type:${list.files[i].mimeType} Url:${list.files[i].thumbnailLink} webViewLink:${list.files[i].webViewLink}");
      }
    });
  }

  Future<void> listboxID(String boxID) async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveFileScope],
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();
    final authHeaders = await user.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    print("listboxID() = $boxID");
    print("driveApi=$authHeaders");
    driveApi.files
        .list(
            q: '"$boxID" in parents',
            pageSize: null,
            supportsAllDrives: false,
            $fields: "files(id, name, mimeType, thumbnailLink)")
        .then((value) {
      setState(() {
        list = value;
        list2 = value;
      });
      for (var i = 0; i < list.files.length; i++) {
        print("Number:${[
          i + 1
        ]} Id: ${list.files[i].id} File Name:${list.files[i].name} Type:${list.files[i].mimeType} Url:${list.files[i].thumbnailLink}");
        setState(() {
          nameBox = 'BOX';
          idBox = boxID;
        });
      }
    });
  }

  Future<void> deleteFolder(String fileName, String googledriveID) async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveFileScope],
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();

    final authHeaders = await user.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    final result = await driveApi.files.delete(googledriveID);
    print("Delete file ID: $googledriveID Result: ");
    listGoogleDriveFiles(nameBox, idBox);
  }

  List<Widget> generateFilesWidget() {
    List<Widget> listItem = List<Widget>();
    if (list != null) {
      for (var i = 0; i < list.files.length; i++) {
        Widget leadingIcon;
        if (list.files[i].mimeType.contains("folder")) {
          leadingIcon = Icon(
            Icons.folder,
            color: Colors.amber,
            size: 100,
          );
          listItem.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: ListTile(
                        leading: leadingIcon,
                        title: Text(list.files[i].name),
                        onTap: () {
                          setState(() {
                            folderID = list.files[i].id;
                            folderName = list.files[i].name;
                            folderBoxID = boxID;
                            folderSearch = null;
                          });
                          sendValueToBOX(context);
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 205.0,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            child: Icon(
                              Icons.edit,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                picID = list.files[i].id;
                                picName = list.files[i].name;
                              });
                              picturename2();
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              deleteFolder(
                                  list.files[i].name, list.files[i].id);
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        } else if (list2 != null) {
          listItem.add(Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Container(
                  height: 250.0,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text('รอซักครู่....'),
                ),
              ])));
        }
      }
    }
    return listItem;
  }

  createFolder() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveFileScope],
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();

    final authHeaders = await user.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    final driveFile = new drive.File();

    driveFile.parents = ["$idBox"];
    driveFile.name = '$newName';
    driveFile.mimeType = "application/vnd.google-apps.folder";
    final result = await driveApi.files.create(driveFile);
    print("Upload result: $result");
    listGoogleDriveFiles(nameBox, idBox);
  }

  createFolderBOX() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveFileScope],
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();

    final authHeaders = await user.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    final driveFile = new drive.File();

    driveFile.name = 'BOX';
    driveFile.mimeType = "application/vnd.google-apps.folder";
    final result = await driveApi.files.create(driveFile);
    print("Upload result: $result");
    checkBOX();
  }

  Future<void> listGoogleDriveFiles2(
      String googledriveNAME, String googledriveID) async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveFileScope],
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();
    String idBox2 = googledriveID;
    String nameBox2 = googledriveNAME;
    final authHeaders = await user.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    print('googledriveID: $googledriveID');
    print('googledriveIDBox: $googledriveID');
    driveApi.files
        .list(
            q: "'$googledriveID' in parents",
            pageSize: null,
            supportsAllDrives: false,
            spaces: "drive",
            $fields: "files(id, name, mimeType, thumbnailLink, webViewLink)")
        .then((value) {
      setState(() {
        list = value;
      });
      for (var i = 0; i < list.files.length; i++) {
        print("Number:${[
          i + 1
        ]} Id: ${list.files[i].id} File Name:${list.files[i].name} Type:${list.files[i].mimeType} Url:${list.files[i].thumbnailLink} webViewLink:${list.files[i].webViewLink}");
      }
      setState(() {
        idBox = idBox2;
        nameBox = nameBox2;
      });
    });
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      builder: (_) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                onChanged: (value) => newName = value,
                autofocus: true,
                decoration:
                    new InputDecoration(labelText: 'ชื่อกล่อง', hintText: ''),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                print('newName: $newName');
                Navigator.pop(context);
                createFolder();
              })
        ],
      ),
    );
  }

  final myController = TextEditingController();
  shareBOX() async {
    await showDialog<String>(
      context: context,
      builder: (_) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                controller: myController,
                onChanged: (value) => shareName = value,
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'อีเมลล์ที่ต้องการแชร์', hintText: ''),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                print('shareName: $shareName');
                Navigator.pop(context);
                share();
              })
        ],
      ),
    );
  }

  search() async {
    await showDialog<String>(
      context: context,
      builder: (_) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                onChanged: (value) => searchName = value,
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'ชื่อสิ่งของที่ต้องการค้นหา', hintText: ''),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new TextButton(
              child: const Text('ค้นหา'),
              onPressed: () {
                print('searchName: $searchName');
                Navigator.pop(context);
                setState(() {
                  folderSearch = searchName;
                  folderBoxID = boxID;
                  folderID = idBox;
                  folderName = nameBox;
                });
                sendValueToBOX(context);
              })
        ],
      ),
    );
  }

  Future rename() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveFileScope],
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();
    final authHeaders = await user.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    final driveFile = drive.File();
    driveFile.name = '$picName';
    driveApi.files.update(driveFile, picID);
    print('เปลี่ยนชื่อสำเร็จ');
    setState(() {
      list = null;
    });

    driveApi.files
        .list(
            q: '"$idBox" in parents',
            supportsAllDrives: false,
            spaces: "drive",
            $fields: "files(id, name, mimeType, thumbnailLink)")
        .then((value) {
      setState(() {
        list = null;
        list2 = value;
      });
      listGoogleDriveFiles(nameBox, idBox);
    });
  }

  picturename2() async {
    await showDialog<String>(
      context: context,
      builder: (_) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                onChanged: (value) => picName = value,
                autofocus: true,
                decoration:
                    new InputDecoration(labelText: 'ชื่อกล่อง', hintText: ''),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                print('picName: $picName');
                Navigator.pop(context);
                rename();
              })
        ],
      ),
    );
  }

  List<Widget> generateFilesWidget2() {
    List<Widget> listItem2 = List<Widget>();
    if (nameBox == 'BOX') {
      listItem2.add(
        _showDialog(),
      );
    }
    return listItem2;
  }

  Future sendValueToBOX(BuildContext context) async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();
    GoogleSignInAuthentication userAuth = await user.authentication;

    await _auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: userAuth.idToken, accessToken: userAuth.accessToken));
    checkAuth2(context);
  }

  Future share() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveFileScope],
      //scopes: ['https://www.googleapis.com/drive/v3/files/fileId/permissions'],
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();
    final authHeaders = await user.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    final driveFile = new drive.Permission();

    driveFile.role = 'writer';
    driveFile.type = 'user';
    driveFile.emailAddress = myController.text.toString(); //'$shareName';
    print('ดักดู   ${driveFile.emailAddress}+' +
        myController.text.toString() +
        boxID);
    // driveFile.kind = 'drive#permission';
    // driveFile.id = '06163652592434522150';
    final result =
        await driveApi.permissions.create(driveFile, boxID.toString());
    print(result);
    print('Share folder to $shareName +' + myController.text.toString());
    _share();
  }

  _share() async {
    await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "แชร์สำเร็จ🎉",
          style: new TextStyle(
            color: Color.fromARGB(255, 10, 111, 200),
          ),
        ),
        content: Text(
          "คุณได้แชร์ข้อมูลให้กับ " + myController.text.toString(),
          style: new TextStyle(
            color: Color.fromARGB(255, 10, 111, 200),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              "รับทราบ",
              style: new TextStyle(color: Color.fromARGB(255, 10, 111, 200)),
            ),
          ),
        ],
      ),
    );
  }
}
