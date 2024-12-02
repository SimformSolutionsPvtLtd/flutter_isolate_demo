import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';

class MultipleIsolateBetterManagement extends StatefulWidget {
  const MultipleIsolateBetterManagement({super.key});

  @override
  State<MultipleIsolateBetterManagement> createState() =>
      _MultipleIsolateBetterManagementState();
}

class _MultipleIsolateBetterManagementState
    extends State<MultipleIsolateBetterManagement> {
  List<ReceivePort> localReceivePorts =
      List.generate(Platform.numberOfProcessors - 2, (index) => ReceivePort());

  List<ReceivePort> isolateReceivePorts =
  List.generate(Platform.numberOfProcessors - 2, (index) => ReceivePort());

  void createIsolates() {
    var isolateIndex = 0;
    for (final localReceivePort in localReceivePorts) {
      Isolate.spawn(heavyFunction, [localReceivePort.sendPort, isolateIndex]);
      localReceivePort.listen((data) {
        if (data is ReceivePort) {
          isolateReceivePorts.add(data);
        } else if (data is CompleteIsolateIndex) {
          isolateReceivePorts[data.index].sendPort.send('upload');
        }
      });
    }
  }

  static void heavyFunction(List data) {
    final sendPort = data[0] as SendPort;
    final currentIsolateIndex = data[1] as int;
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort);
    receivePort.listen((data) async {
      if (data is String) {
        Future.delayed(const Duration(seconds: 4));
        sendPort.send(CompleteIsolateIndex(currentIsolateIndex));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class CompleteIsolateIndex {
  CompleteIsolateIndex(this.index);
  final int index;
}
