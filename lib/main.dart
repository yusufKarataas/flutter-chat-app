import 'package:chattingapp/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  startApiServer();
  runApp(const MainApp());
}

void startApiServer() {
  Process.start(
        '/home/yusuf/.nvm/versions/node/v22.18.0/bin/npm',
        ['run', 'dev'],
        workingDirectory:
            "/home/yusuf/Masaüstü/flutter-chatting-app/chattingapp/api",
        runInShell: true,
      )
      .then((process) {
        stdout.addStream(process.stdout);
        stderr.addStream(process.stderr);
      })
      .catchError((err) {
        print('❌ API sunucusu başlatılamadı: $err');
      });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
