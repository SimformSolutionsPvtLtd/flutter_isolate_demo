import 'dart:isolate';

import 'package:flutter/material.dart';

class SpawnIsolateTwoWay extends StatefulWidget {
  const SpawnIsolateTwoWay({super.key});

  @override
  State<SpawnIsolateTwoWay> createState() => _SpawnIsolateTwoWayState();
}

class _SpawnIsolateTwoWayState extends State<SpawnIsolateTwoWay> {
  var response = "Response";

  final rcvPort = ReceivePort();

  SendPort? sendPortFromIsolate;

  Isolate? isolate;

  @override
  void initState() {
    super.initState();

    createIsolates();
  }

  Future<void> createIsolates() async {
    isolate = await Isolate.spawn<CreateIsolateData>(
        heavyTask, CreateIsolateData(rcvPort.sendPort));

    rcvPort.listen((data) {
      if (data is SendPort) {
        sendPortFromIsolate = data;
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
      appBar: AppBar(
        title: const Text('Spawn Isolate Two way'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(response),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Start Upload'),
              onPressed: () {
                sendPortFromIsolate?.send(StartUploadEvent(5));
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Cancel Item 2'),
              onPressed: () {
                sendPortFromIsolate?.send(CancelItemUploadEvent(2));
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('stop Isolate'),
              onPressed: () {
                sendPortFromIsolate?.send(StopUploadEvent());
              },
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

void heavyTask(CreateIsolateData createIsolateData) {
  final sendPort = createIsolateData.sendPort;
  final rcvPort = ReceivePort();

  var stopUpload = false;
  final List<int> cancelItem = [];

  sendPort.send(rcvPort.sendPort);

  rcvPort.listen((data) async {
    if (data is StartUploadEvent) {
      stopUpload = false;
      for (var itemIndex = 0; itemIndex < data.itemCount; itemIndex++) {
        if (!cancelItem.contains(itemIndex)) {
          var percentage = 0;
          for (var progress = 0; progress < 5; progress++) {
            if (stopUpload) {
              sendPort.send('Uploading Stopped');
              return;
            }
            sendPort.send('$itemIndex is $percentage% uploaded');
            await Future.delayed(const Duration(seconds: 2));
            percentage += 20;
          }
        }
      }
    } else if (data is CancelItemUploadEvent) {
      cancelItem.add(data.index);
      return;
    } else if (data is StopUploadEvent) {
      stopUpload = true;
    }
  });
}

/// Models
class StartUploadEvent {
  StartUploadEvent(this.itemCount);

  final int itemCount;
}

class StopUploadEvent {}

class CancelItemUploadEvent {
  CancelItemUploadEvent(this.index);

  final int index;
}

class CreateIsolateData {
  CreateIsolateData(this.sendPort);

  final SendPort sendPort;
}
