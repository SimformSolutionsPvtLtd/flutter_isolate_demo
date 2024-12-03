import 'dart:isolate';

import 'package:flutter/material.dart';

class SpawnIsolateTwoWay extends StatefulWidget {
  const SpawnIsolateTwoWay({super.key});

  @override
  State<SpawnIsolateTwoWay> createState() => _SpawnIsolateTwoWayState();
}

class _SpawnIsolateTwoWayState extends State<SpawnIsolateTwoWay> {
  var response = "Response";


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
                // start upload event
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Cancel Item 2'),
              onPressed: () {
                //cancel item
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Stop Isolate'),
              onPressed: () {
                //stop upload
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('kill Isolate'),
              onPressed: () {
                //kill upload
              },
            )
          ],
        ),
      ),
    );
  }
}

void heavyTask(IsolateData message) async {
  var stopUpload = false;
  final List<int> cancelItem = [];
  for (var itemIndex = 0; itemIndex < 4; itemIndex++) {
    if (!cancelItem.contains(itemIndex)) {
      var percentage = 0;
      for (var progress = 0; progress < 5; progress++) {
        if (stopUpload) {
          debugPrint('Uploading Stopped');
          return;
        }
        // send progress here
        debugPrint('$itemIndex is $percentage% uploaded');
        await Future.delayed(const Duration(seconds: 2));
        percentage += 20;
      }
    }
  }
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

class IsolateData {
  IsolateData(this.sendPort);

  final SendPort sendPort;
}
