import 'package:flutter/material.dart';
import '../widgets/track_list.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music Player"),
      ),
//      body: TrackList(),
    );
  }
}
