import 'package:flutter/foundation.dart';

class PlayerProvider with ChangeNotifier {
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  void playTrack() {
    _isPlaying = true;
    notifyListeners();
  }

  void pauseTrack() {
    _isPlaying = false;
    notifyListeners();
  }
}
