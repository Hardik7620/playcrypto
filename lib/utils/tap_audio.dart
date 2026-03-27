// @global

import 'package:audioplayers/audioplayers.dart';

clickSound() async {
  AudioPlayer().play(
    AssetSource('sounds/click_sound.mp3'),
    volume: .4,
    mode: PlayerMode.lowLatency,
  );
}
