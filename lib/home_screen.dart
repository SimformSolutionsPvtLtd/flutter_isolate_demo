import 'package:flutter/material.dart';
import 'package:isolate_template/isolate_run.dart';
import 'package:isolate_template/spawn_isolate_one_way.dart';
import 'package:isolate_template/spawn_isolate_two_way.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Isolate'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => navigate(
                const IsolateRun(),
              ),
              child: const Text('Isolate run'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigate(
                const SpawnIsolateOneWay(),
              ),
              child: const Text('Spawn isolate one way'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigate(
                const SpawnIsolateTwoWay(),
              ),
              child: const Text('Spawn isolate two way'),
            ),
          ],
        ),
      ),
    );
  }

  void navigate(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }
}
