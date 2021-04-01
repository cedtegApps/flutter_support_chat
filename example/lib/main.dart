// Flutter imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_support_chat/flutter_support_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login.dart';

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
      body: StreamBuilder<User?>(
        builder: (BuildContext context, AsyncSnapshot<User?> s) {
          if (s.connectionState == ConnectionState.active) {
            if (s.hasData) {
              return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      final User user = snapshot.data!;
                      return FlutterSupportChat(
                        currentEmail: user.email!,
                        newCaseText: 'New Support Case',
                        supporterEmails: [
                          'cedtegapps.de@gmail.com',
                        ],
                        firestoreInstance: FirebaseFirestore.instance,
                      );
                    }
                  }
                  return RefreshProgressIndicator();
                },
              );
            }
            return Login();
          }
          return RefreshProgressIndicator();
        },
        stream: FirebaseAuth.instance.authStateChanges(),
      ),
    );
  }
}
