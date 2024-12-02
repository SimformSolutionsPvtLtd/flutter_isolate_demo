import 'dart:isolate';

import 'package:flutter/material.dart';

class SpawnIsolateTwoWay extends StatefulWidget {
  const SpawnIsolateTwoWay({super.key});

  @override
  State<SpawnIsolateTwoWay> createState() => _SpawnIsolateTwoWayState();
}

class _SpawnIsolateTwoWayState extends State<SpawnIsolateTwoWay> {
  var response = "";

  final rcvPort = ReceivePort();

  SendPort? sendPort;

  @override
  void initState() {
    super.initState();

    createIsolates();
  }

  Future<void> createIsolates() async {
    Isolate.spawn<List>(heavyTask, [rcvPort.sendPort]);

    rcvPort.listen((data) {
      if (data is SendPort) {
        sendPort = data;
      } else {
        setState(() {
          response = data as String;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            Text(response),
            ElevatedButton(
              onPressed: () {
                sendPort?.send(1);
              },
              child: const Text('upload with isolate'),
            ),
            ElevatedButton(
              onPressed: () {
                sendPort?.send(1);
              },
              child: const Text('upload without isolate'),
            )
          ],
        ),
      ),
    );
  }
}

void heavyTask(List args) {
  final a = args[0] as SendPort;
  final rcvPort = ReceivePort();
  a.send(rcvPort.sendPort);
  rcvPort.listen((data) async {
    if (data as bool) {
      // stop enum

      // a.send();
      return;

    }
    var percentage = 0;
    for (var itemCount = 0; itemCount < 5; itemCount++) {
      await Future.delayed(const Duration(seconds: 1));
      percentage += 20;
      a.send('$data is $percentage uploaded');
    }
  });
}
