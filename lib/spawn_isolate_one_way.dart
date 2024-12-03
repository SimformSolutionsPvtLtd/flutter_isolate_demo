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
        onPressed: () {
          // create isolate here
        },
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
      sum += findPrimes(data);
    }
  }
}


int findPrimes(int a) {
  final int maxNumber = a;

  final List<int> primes = [];

  for (int i = 2; i <= maxNumber; i++) {
    if (isPrime(i)) {
      primes.add(i);
    }
  }
  return primes.last;
}

// Helper function to check if a number is prime
bool isPrime(int number) {
  if (number < 2) return false;
  for (int i = 2; i <= number ~/ 2; i++) {
    if (number % i == 0) return false;
  }
  return true;
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
