import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String? _currentAsset;

  bool get isPlaying => _isPlaying;

  Future<void> playAsset(String assetPath) async {
    if (_isPlaying) {
      await stop();
    }
    await _player.setSourceAsset(assetPath);
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.resume();
    _isPlaying = true;
    _currentAsset = assetPath;
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _currentAsset = null;
  }

  Future<void> resume() async {
    if (_currentAsset != null) {
      await _player.resume();
      _isPlaying = true;
    }
  }

  void dispose() {
    _player.dispose();
  }
}
