import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/civicinfo/v2.dart';
import 'package:googleapis/cloudasset/v1.dart';

class Mydev extends StatefulWidget {
  Mydev({Key key}) : super(key: key);
  @override
  _MydevState createState() => _MydevState();
}

class _MydevState extends State<Mydev> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.yellow[100],
              Colors.green[100],
            ],
          ),
        ),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  textWellcome(),
                  gap(),
                  gap(),
                  gap(),
                  showUserPicture(),
                  pea(),
                  gap(),
                  gap(),
                  gap(),
                  gap(),
                  showLogo(),
                  showUsername(),
                  gap(),
                  gap(),
                  gap(),
                  gap(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container textWellcome() {
    return Container(
      child: Text(
        "ผู้พัฒนาแอปพลิเคชัน",
        style: new TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Container pea() {
    return Container(
      child: Text(
        "นายทินกร  ดวงอินทร์",
        style: new TextStyle(fontSize: 25.0),
      ),
    );
  }

  Container showLogo() {
    return Container(
      width: 120.0,
      child: Image.asset('images/f.jfif'), 
    );
  }

  Container gap() {
    return Container(
      width: 120.0,
      height: 20.0,
    );
  }

  Container showUserPicture() {
    return Container(
      width: 120.0,
      child: Image.asset('images/pea.jpg'),
    );
  }

  Container showUsername() {
    return Container(
      child: Text(
        'นายยศพัฒน์  จอมทรักษ์',
        style: new TextStyle(fontSize: 25.0),
      ),
    );
  }
}
