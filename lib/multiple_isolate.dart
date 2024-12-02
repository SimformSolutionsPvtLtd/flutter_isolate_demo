import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';

class ListItems extends StatefulWidget {
  const ListItems({super.key});

  @override
  ListItemsState createState() => ListItemsState();
}

class ListItemsState extends State<ListItems> {
  final Album albumA = Album(id: 1, items: [
    for (var i = 1; i <= 3; i++)
      FileDm(
        label: 'A$i',
        albumId: 1,
      )
  ]);
  final Album albumB = Album(id: 2, items: [
    for (var i = 1; i <= 6; i++)
      FileDm(
        label: 'B$i',
        albumId: 2,
      )
  ]);
  final Album albumC = Album(id: 3, items: [
    for (var i = 1; i <= 9; i++)
      FileDm(
        label: 'C$i',
        albumId: 3,
      )
  ]);
  final Album albumD = Album(id: 4, items: [
    for (var i = 1; i <= 3; i++)
      FileDm(
        label: 'D$i',
        albumId: 4,
      )
  ]);
  final Album albumE = Album(id: 5, items: [
    for (var i = 1; i <= 4; i++)
      FileDm(
        label: 'E$i',
        albumId: 5,
      )
  ]);
  final Album albumF = Album(id: 6, items: [
    for (var i = 1; i <= 7; i++)
      FileDm(
        label: 'F$i',
        albumId: 6,
      )
  ]);
  final Album albumG = Album(id: 7, items: [
    for (var i = 1; i <= 2; i++)
      FileDm(
        label: 'G$i',
        albumId: 7,
      )
  ]);
  final Album albumH = Album(id: 8, items: [
    for (var i = 1; i <= 1; i++)
      FileDm(
        label: 'H$i',
        albumId: 8,
      )
  ]);
  final Album albumI = Album(id: 9, items: [
    for (var i = 1; i <= 5; i++)
      FileDm(
        label: 'I$i',
        albumId: 9,
      )
  ]);
  final Album albumJ = Album(id: 10, items: [
    for (var i = 1; i <= 1; i++)
      FileDm(
        label: 'J$i',
        albumId: 10,
      )
  ]);
  final Album albumK = Album(id: 11, items: [
    for (var i = 1; i <= 2; i++)
      FileDm(
        label: 'K$i',
        albumId: 11,
      )
  ]);

  final List<FileDm> canceledItems = [];

  late final List<Album> albums = [
    albumA, // 3 - 1
    albumB, // 4 - 6
    albumC, // 5
    albumD, // 2
    albumE,
    albumF,
    albumG,
    albumH,
    albumI,
    albumJ,
    albumK,
  ];


  List<FileDm> totalItem = [];
  int index = 0;
  final List<FileDm> _completedItems = [];

  final Map<int, Isolate> _isolates = {};
  final Map<int, SendPort> sendPorts = {};
  late ReceivePort _receivePort;
  final _numIsolates = (Platform.numberOfProcessors / 2).ceil();

  @override
  void initState() {
    super.initState();
    debugPrint('Total isolates $_numIsolates');
    for (var album in albums) {
      totalItem.addAll(album.items);
    }
    _receivePort = ReceivePort();
    _startUpload();
  }

  @override
  void dispose() {
    _isolates.forEach((k, v) {
      v.kill(priority: Isolate.immediate);
    });
    _receivePort.close();
    super.dispose();
  }

  void _startUpload() async {
    _receivePort.listen((message) {
      if (message == 'Completed') {
        index++;

        if (index >= albums.length) {
          return;
        }
        _createIsolate(albums[index]);
      } else if (message is FileDm) {
        setState(() {
          final file =
          totalItem.firstWhere((file) => file.label == message.label);
          file.fileStatus = FileStatus.completed;
          _completedItems.add(file);
        });
      } else if (message is List) {
        final albumId = message[0];
        final sendPort = message[1];
        sendPorts[albumId] = sendPort;
      }
    });

    final subList = albums.sublist(0, _numIsolates.ceil() - 1);

    index = subList.length - 1;
    for (var i in subList) {
      _createIsolate(i);
    }
  }

  Future<void> _createIsolate(Album album) async {
    final isolate = await Isolate.spawn(
      _uploadProcessor,
      [_receivePort.sendPort, album, canceledItems],
    );

    _isolates[album.id] = isolate;
    // _isolates[album.id]?.kill(priority: Isolate.immediate);
  }

  static Future<void> _uploadProcessor(List<dynamic> args) async {
    SendPort mainSendPort = args[0];
    Album album = args[1];

    List<FileDm> cancelItems = [];
    List<FileDm> additionalItems = []; // you need to handle additional item
    // here

    cancelItems.addAll(args[2]);

    final isolateReceivePort = ReceivePort();
    mainSendPort.send([album.id, isolateReceivePort.sendPort]);

    // Listen for messages from the main isolate
    isolateReceivePort.listen((message) {
      if (message is FileDm) {
        cancelItems.add(message);
      }
    });

    for (var item in album.items) {
      if (cancelItems.indexWhere((e) => e.label == item.label) < 0) {
        await Future.delayed(const Duration(seconds: 2));
        mainSendPort.send(item);
      } else {
        debugPrint('Item skip for the ${item.label}');
      }
    }
    mainSendPort.send('Completed');
  }

  void _cancelUpload(FileDm item) {
    setState(() {
      item.fileStatus = FileStatus.cancelled;
      canceledItems.add(item);
      sendPorts[item.albumId]?.send(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Album Upload Processor")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Total Uploads: ${totalItem.length}"),
            Text("Completed Uploads: ${_completedItems.length}"),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _completedItems.length / totalItem.length,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: totalItem.length,
                itemBuilder: (context, index) {
                  final item = totalItem[index];

                  return ListTile(
                    title: Text("Task: ${item.label}"),
                    subtitle: Text(item.fileStatus == FileStatus.completed
                        ? "Status: Completed"
                        : item.fileStatus == FileStatus.cancelled
                        ? "Status: Canceled"
                        : "Status: In Progress"),
                    trailing: item.fileStatus == FileStatus.completed ||
                        item.fileStatus == FileStatus.cancelled
                        ? null
                        : ElevatedButton(
                      onPressed: () => _cancelUpload(item),
                      child: const Text("Cancel"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static int getRandom(int min, int max) {
    final random = Random();

    return min + random.nextInt(max - min);
  }
}

class Album {
  final int id;
  final List<FileDm> items;

  Album({required this.id, required this.items});
}

class FileDm {
  final String label;
  FileStatus fileStatus = FileStatus.inProcess;
  final int albumId;

  FileDm({
    required this.label,
    required this.albumId,
    this.fileStatus = FileStatus.inProcess,
  });
}

enum FileStatus {
  cancelled,
  inProcess,
  completed,
}