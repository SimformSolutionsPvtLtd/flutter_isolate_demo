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

  Isolate? isolate;

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
        onPressed: () => createIsolate(100000),
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  Future<void> createIsolate(int range) async {
    // Create a ReceivePort to get data back from the isolate
    final receivePort = ReceivePort();

    // Spawn the isolate
    isolate = await Isolate.spawn(
        _heavyComputation,
        IsolateData(
          value: 10000,
          sendPort: receivePort.sendPort,
          times: 5,
        ));
    receivePort.listen((data) {
      setState(() {
        result = 'Sum of squares: ${data as int}';
      });
    });
  }

  static void _heavyComputation(IsolateData message) async {
    final replyPort = message.sendPort;
    final data = message.value; // Range
    final times = message.times; // Range

    // Perform heavy computation
    int sum = 0;
    for (int j = 1; j <= times; j++) {
      for (int i = 1; i <= data; i++) {
        sum += i * i;
      }
      await Future.delayed(const Duration(seconds: 3));
      replyPort?.send(sum + j);
    }
  }

  @override
  void dispose() {
    super.dispose();

    isolate?.kill(priority: Isolate.immediate);
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
