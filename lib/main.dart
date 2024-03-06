import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/firebase_options.dart';
import 'package:modernlogintute/pages/menu.dart';
import 'package:modernlogintute/pages/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform, );

runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'My App',
    theme: ThemeData( primarySwatch: Colors.blue, ),
    home: Welcome(),
    routes: {
      '/menu': (context) => menu(),
    },
  );
}
}