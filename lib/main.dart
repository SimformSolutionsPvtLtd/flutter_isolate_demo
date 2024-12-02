
import 'package:flutter/material.dart';
import 'package:isolate_template/isolate_large_video.dart';
import 'package:isolate_template/isolate_run.dart';
import 'package:isolate_template/spawn_isolate_two_way.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoadVideoPage(),
      // home: const IsolateRun(),
      // home: SpawnIsolateOneWay(),
      // home: SpawnIsolatesTwoWay(),
    );
  }
}
