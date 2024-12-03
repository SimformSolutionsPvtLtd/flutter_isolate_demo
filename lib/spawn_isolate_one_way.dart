import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

class SpawnIsolateOneWay extends StatefulWidget {
  const SpawnIsolateOneWay({super.key});

  @override
  SpawnIsolateOneWayState createState() => SpawnIsolateOneWayState();
}

class SpawnIsolateOneWayState extends State<SpawnIsolateOneWay> {
  String result = 'Tap the button to start computation';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spawn Isolate One way'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(result, textAlign: TextAlign.center),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  static void _heavyComputation(IsolateData message) async {
    final data = message.value; // Range
    final times = message.times; // Range

    // Perform heavy computation
    int sum = 0;
    for (int j = 1; j <= times; j++) {
      for (int i = 1; i <= data; i++) {
        sum += i * i;
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

}

class IsolateData {
  IsolateData({
    required this.sendPort,
    required this.value,
    required this.times,
  });

  final SendPort? sendPort;
  final int value;
  final int times;
}
