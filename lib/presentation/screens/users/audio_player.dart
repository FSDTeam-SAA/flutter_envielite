import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/core/controller/audio_service.dart';

class AudioPlayerWidget extends StatelessWidget {
  final AudioService _audioService = Get.find();

  AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_audioService.isPlaying.value) {
        return const SizedBox.shrink(); // Hide the player if no audio is playing
      }

      print("audio play -> ${_audioService.isPlaying}");

      return Column(
        children: [
          Slider(
            value: _audioService.currentPosition.value.inMilliseconds.toDouble(),
            max: _audioService.duration.value.inMilliseconds.toDouble(),
            onChanged: (value) {
              _audioService.seek(Duration(milliseconds: value.toInt()));
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: _audioService.resumeAudio,
              ),
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: _audioService.pauseAudio,
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: _audioService.stopAudio,
              ),
            ],
          ),
        ],
      );
    });
  }
}