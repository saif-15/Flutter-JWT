import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jwt_example/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController username;
  TextEditingController password;

  @override
  void initState() {
    username = TextEditingController(text: "");
    password = TextEditingController(text: "");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var service = UploadService();

    return Scaffold(
      appBar: AppBar(
        title: Text("JWT Example"),
        centerTitle: true,
        elevation: 10,
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: TextFormField(
                  controller: username,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter username',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: TextFormField(
                  controller: password,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter password',
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  child: TextButton(
                      onPressed: () {
                        if (username.text.isNotEmpty &&
                            password.text.isNotEmpty) {
                          service
                              .login(username.text.toString(),
                                  password.text.toString())
                              .then((value) {
                            saveValue(value);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SecondPage(
                                      token: value,
                                    )));
                          });
                        }
                      },
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                      child: Text("Login"))),
            ],
          ),
        ),
      ),
    );
  }

  saveValue(value) async {
    var pref = await SharedPreferences.getInstance();
    await pref.setString("jwt", value);
  }
}

class SecondPage extends StatefulWidget {
  String token;

  SecondPage({Key key, this.token}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String selectedFile = "";
  String selectedFilename = "";
  SharedPreferences pref;
  String content = "";

  Future<String> getValue() async {
    pref = await SharedPreferences.getInstance();
    pref.getString("jwt");
  }

  @override
  Widget build(BuildContext context) {
    var service = UploadService();
    return Scaffold(
        appBar: AppBar(
          title: Text("Upload"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Token:"),
                  Text(widget.token ?? "na"),
                  TextButton(
                      onPressed: () async {
                        service
                            .openFilePicker()
                            .then((value) => {setValue(value)});
                      },
                      child: Text("Select")),
                  Text("Selected File :" + selectedFile),
                  TextButton(
                      onPressed: () {
                        service
                            .uploadFile(
                                widget.token, selectedFile, selectedFilename)
                            .then((value) {
                          setContent(value);
                        });
                      },
                      child: Text("Upload")),
                  Text("Content :" + content),
                ],
              ),
            ),
          ),
        ));
  }

  setValue(FileInfo value) {
    setState(() {
      selectedFile = value.path;
      selectedFilename = value.name;
    });
  }

  setContent(String value) {
    setState(() {
      content = value;
    });
  }
}
