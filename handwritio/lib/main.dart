import 'package:flutter/material.dart';
import 'package:handwritio/pages/welcome_screen.dart';

void main() {
  runApp(HandwritioApp());
}

class HandwritioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Handwritio',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WelcomeScreen(),
    );
  }
}
