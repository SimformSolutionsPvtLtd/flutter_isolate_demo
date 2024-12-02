import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



class LoadVideoPage extends StatefulWidget {
  @override
  _LoadVideoPageState createState() => _LoadVideoPageState();
}

class _LoadVideoPageState extends State<LoadVideoPage> {
  XFile? _video;

  Future<void> _loadVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedVideo = await picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      _video = pickedVideo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Load Video Without Isolate')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _video == null
                ? const Text('No video selected')
                : Text('Video loaded: ${_video!.path}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadVideo,
              child: const Text('Select Video'),
            ),
          ],
        ),
      ),
    );
  }
}