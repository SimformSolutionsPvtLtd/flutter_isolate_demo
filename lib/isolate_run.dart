import 'dart:isolate';

import 'package:flutter/material.dart';

class IsolateRun extends StatefulWidget {
  const IsolateRun({super.key});

  @override
  State<IsolateRun> createState() => _IsolateRunState();
}

class _IsolateRunState extends State<IsolateRun> {
  var lastPrimeValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Isolate Run'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(),
            Text('Last prime value is $lastPrimeValue')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: findLastPrimeValue,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
  static int staticVariable = 0;

  void findLastPrimeValue() async {
    // final value = findPrimes(500000);
    final value = await Isolate.run(() => findPrimes(staticVariable));
    setState(() {
      lastPrimeValue = value;
    });
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
