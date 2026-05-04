import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Records the child, then plays it back faster for a light “cute” voice.
/// True pitch-shifting would need native DSP; higher playback speed is free
/// and works across platforms supported by [just_audio].
final class PeatVoice {
  PeatVoice() : _recorder = AudioRecorder(), _player = AudioPlayer();

  final AudioRecorder _recorder;
  final AudioPlayer _player;

  String? _recordingPath;
  bool _disposed = false;

  Future<bool> ensureMic() async {
    final s = await Permission.microphone.request();
    return s.isGranted;
  }

  Future<void> startRecording() async {
    if (_disposed) return;
    final ok = await _recorder.hasPermission();
    if (!ok) return;
    final dir = await getTemporaryDirectory();
    _recordingPath =
        '${dir.path}${Platform.pathSeparator}peat_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _recordingPath!,
    );
  }

  Future<void> stopRecordingAndPlayCute() async {
    if (_disposed) return;
    if (!await _recorder.isRecording()) return;
    final path = await _recorder.stop();
    final use = path ?? _recordingPath;
    if (use == null || !File(use).existsSync()) return;
    await _player.stop();
    await _player.setFilePath(use);
    await _player.setSpeed(1.42);
    await _player.play();
  }

  Future<void> cancelRecording() async {
    if (await _recorder.isRecording()) {
      await _recorder.cancel();
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await _player.dispose();
    await _recorder.dispose();
  }
}
