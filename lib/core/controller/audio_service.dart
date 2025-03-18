// services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AudioService extends GetxService {
  final AudioPlayer _player = AudioPlayer();
  final RxString currentPlaying = RxString('');
  final RxBool isPlaying = false.obs;

  @override
  void onInit() {
    _player.onPlayerComplete.listen((_) {
      stopAudio();
    });
    super.onInit();
  }

  bool isAudioPlaying(String audioPath) => currentPlaying.value == audioPath && isPlaying.value;

  Future<void> playAudio(String path) async {
    try {
      if (currentPlaying.value == path && isPlaying.value) return;
      
      await stopAudio();
      
      currentPlaying.value = path;
      isPlaying.value = true;
      await _player.play(DeviceFileSource(path));
    } catch (e) {
      Get.snackbar('Error', 'Could not play audio: $e');
      stopAudio();
    }
  }

  Future<void> pauseAudio() async {
    try {
      await _player.pause();
      isPlaying.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Could not pause audio: $e');
    }
  }

  Future<void> stopAudio() async {
    try {
      await _player.stop();
      currentPlaying.value = '';
      isPlaying.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Could not stop audio: $e');
    }
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}