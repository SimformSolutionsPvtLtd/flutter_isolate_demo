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
      appBar: AppBar(title: const Text('Isolate Example')),
      body: Center(
        child: Column(
          children: [
            Text(result, textAlign: TextAlign.center),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => computeHeavyTask(100000),
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  Future<void> computeHeavyTask(int range) async {
    // Create a ReceivePort to get data back from the isolate
    final receivePort = ReceivePort();

    // Spawn the isolate
    final isolate = await Isolate.spawn(_heavyComputation, [receivePort.sendPort, 10000]);

    receivePort.listen((data) {
      setState(() {
        result = 'Sum of squares: ${data as int}';
      });
    });

    // Clean up the isolate after computation
    isolate.kill(priority: Isolate.immediate);
  }

  static void _heavyComputation(List message) {
    final data = message[0] as int; // Range
    final replyPort = message[1] as SendPort;

    // Perform heavy computation
    int sum = 0;
    for (int i = 1; i <= data; i++) {
      // delay
      sum += i * i;
      // return value from here.
      replyPort.send(sum);
    }

    // Send the result back
  }

}
