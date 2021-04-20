import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

MyApp() {
  return MaterialApp(
    home: AnimatedSplashScreen(
      splash: Image.asset('images/linux.png'),
      nextScreen: home_page(),
      backgroundColor: Colors.black,
      splashTransition: SplashTransition.rotationTransition,
    ),
  );
}

class home_page extends StatefulWidget {
  home_page({Key key}) : super(key: key);

  @override
  _home_pageState createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  var events;
  var val;
  var url;
  var response;
  var fbconnect = FirebaseFirestore.instance;
  Tween<Offset> _offset = Tween(begin: Offset(1, 0), end: Offset(0, 0));
  final _myListKey = GlobalKey<AnimatedListState>();

  run(cmd) async {
    url = "http://54.145.200.109/cgi-bin/web.py?x=${cmd}";
    response = await http.get(url);
    fbconnect.collection("result").add({
      "cmd": cmd,
      "Output": response.body,
      "datetime": DateTime.now(),
    });

    var output = await fbconnect.collection("result").snapshots();
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Linux Terminal App"), backgroundColor: Colors.black),
      body: Container(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                child: Image.asset('images/ubuntu.jpg'),
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: TextFormField(
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        helperStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(color: Colors.black),
                        filled: true,
                        hoverColor: Colors.white,
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        helperText: 'Enter Command',
                        labelText: "Enter command",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onChanged: (value) {
                        val = value;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FlatButton(
                      onPressed: () {
                        run(val);
                      },
                      child: Text(
                        "Run",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      builder: (context, snapshot) {
                        try {
                          if (snapshot.data == null)
                            return CircularProgressIndicator();
                          else {
                            events = snapshot.data.docs;
                          }
                        } catch (e) {
                          print(e);
                        }

                        return Container(
                          child: AnimatedList(
                            initialItemCount:
                                (events.length != null) ? events.length : 0,
                            itemBuilder:
                                (BuildContext context, int index, animation) {
                              // AnimatedList.of(context).insertItem(index);

                              return SlideTransition(
                                position: animation.drive(_offset),
                                child: Card(
                                  color: Colors.black,
                                  child: ListTile(
                                    leading: Text(
                                      events[index].get("cmd") + "-",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20),
                                    ),
                                    title: Text(
                                      events[index].get("Output"),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      stream: fbconnect
                          .collection("result")
                          .orderBy("datetime", descending: true)
                          .snapshots(),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
