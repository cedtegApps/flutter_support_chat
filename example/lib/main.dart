// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_support_chat/flutter_support_chat.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_support_chat example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("flutter_fb_news example"),
      ),
      body: Center(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: FlutterSupportChat(),
          ),
        ),
      ),
    );
  }
}
