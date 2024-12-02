import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SpawnIsolateTwoWay extends StatefulWidget {
  const SpawnIsolateTwoWay({super.key});

  @override
  State<SpawnIsolateTwoWay> createState() => _SpawnIsolateTwoWayState();
}

class _SpawnIsolateTwoWayState extends State<SpawnIsolateTwoWay> {
  var response = "";

  final rcvPort = ReceivePort();

  SendPort? sendPort;

  Isolate? isolate;

  @override
  void initState() {
    super.initState();

    createIsolates();
  }

  Future<void> createIsolates() async {
    isolate = await Isolate.spawn<List>(heavyTask, [rcvPort.sendPort]);

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
            ),
            ElevatedButton(
              onPressed: () {
                sendPort?.send(CancelItemUploadUploadEvent(4));
              },
              child: const Text('Cancel Item 4'),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    isolate?.kill(priority: Isolate.immediate);
  }
}

void heavyTask(List args) {
  final List<int> cancelItem = [];
  final sendPort = args[0] as SendPort;
  final rcvPort = ReceivePort();
  var shouldStop = false;
  sendPort.send(rcvPort.sendPort);
  rcvPort.listen((data) async {
    if (data is StartUploadEvent) {
      var percentage = 0;
      for (var itemIndex = 0; itemIndex < 5; itemIndex++) {
        if (shouldStop) {
          break;
        }
        if (cancelItem.contains(itemIndex)) {
          await Future.delayed(const Duration(seconds: 5));
          percentage += 20;
          sendPort.send('$data is $percentage uploaded');
        }
      }
    } else if (data is CancelItemUploadUploadEvent) {
      cancelItem.add(data.index);
      return;
    } else if (data is StopUploadUploadEvent) {
      shouldStop = true;
    }
  });
}

abstract class UploadEvent {}

class StartUploadEvent extends UploadEvent {}

class StopUploadUploadEvent extends UploadEvent {}

class CancelItemUploadUploadEvent extends UploadEvent {
  CancelItemUploadUploadEvent(this.index);

  final int index;
}
