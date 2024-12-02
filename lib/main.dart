import 'package:flutter/material.dart';
import 'package:isolate_template/home_screen.dart';
import 'package:isolate_template/isolate_large_video.dart';
import 'package:isolate_template/isolate_run.dart';
import 'package:isolate_template/spawn_isolate_one_way.dart';
import 'package:isolate_template/spawn_isolate_two_way.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Isolate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: LoadVideoPage(),
      home: const HomeScreen(),
    );
  }
}
