import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:murottal/app/data/models/surah/surah.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomeController extends GetxController {
  final player = AudioPlayer();

  final speechToText = SpeechToText();
  bool speechEnable = false;
  var words = Rx<String?>(null);

  var isListening = false.obs;
  var isPlaying = false.obs;
  var isPause = false;

  var maxDuration = Rx<Duration?>(null);
  var progressDuration = Rx<Duration?>(null);

  late List<Surah> listSurah;
  var selectedSurah = Rx<Surah?>(null);

  var listAudio = Rx<List<String>>([]);

  var selectedPlayerIndex = 0;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init() {
    observe();
    initData();
    initSpeech();
    initPlayer();
  }

  void observe() {
    listAudio.listen((p0) async {
      if (p0.isNotEmpty) {
        isPlaying.value = true;
        await player.play(UrlSource(p0[selectedPlayerIndex]));
      }
    });
  }

  void initData() {
    getSurah();
  }

  void getSurah() async {
    final json = await DefaultAssetBundle.of(Get.context!)
        .loadString('assets/json/surah.json');

    listSurah =
        (jsonDecode(json) as List).map((e) => Surah.fromMap(e)).toList();
  }

  void initSpeech() async {
    speechEnable = await speechToText.initialize();
  }

  void initPlayer() {
    player.onDurationChanged.listen((event) {
      maxDuration.value = event;
    });

    player.onPositionChanged.listen((event) {
      progressDuration.value = event;
    });

    player.onPlayerComplete.listen((event) {
      isPlaying.value = false;
      maxDuration.value = Duration.zero;
      progressDuration.value = Duration.zero;

      selectedPlayerIndex += 1;

      if (selectedPlayerIndex < listAudio.value.length) {
        listAudio.refresh();
      }
    });
  }

  void startListening() async {
    if (isListening.value) {
      speechToText.stop();
      isListening.value = false;
    } else {
      isListening.value = true;

      await player.pause();
      isPlaying.value = false;

      await speechToText.listen(
        onResult: (result) async {
          words.value = result.recognizedWords;

          if (words.value != null) {
            final surah = listSurah.firstWhereOrNull((e) =>
                words
                    .toLowerCase()
                    ?.contains(e.transliteration!.toLowerCase()) ??
                false);

            if (surah != null) {
              selectedSurah.value = surah;

              final numSurah = surah.id.toString().padLeft(3, '0');
              final startAt = '001';
              final endAt = surah.totalVerses.toString().padLeft(3, '0');

              listAudio.value.clear();

              for (var i = int.parse(startAt); i <= int.parse(endAt); i++) {
                final verse = i.toString().padLeft(3, '0');
                final url =
                    'https://everyayah.com/data/Alafasy_128kbps/$numSurah$verse.mp3';
                listAudio.value.add(url);
              }

              selectedPlayerIndex = 0;
              listAudio.refresh();
            }
          }

          isListening.value = speechToText.isListening;

          if (speechToText.isNotListening && selectedSurah.value == null) {
            showToast(
              'Maaf perintah belum dapat di mengerti oleh sistem',
              context: Get.overlayContext,
              animation: StyledToastAnimation.fade,
              reverseAnimation: StyledToastAnimation.fade,
            );
          }
        },
      );
    }
  }

  void play() async {
    if (isPlaying.value) {
      isPause = true;
      isPlaying.value = false;
      await player.pause();
    } else {
      isPlaying.value = true;

      if (isPause) {
        isPause = false;
        await player.resume();
      } else {
        if (listAudio.value.isEmpty) {
          startListening();
        } else {
          selectedPlayerIndex = 0;
          listAudio.refresh();
        }
      }
    }
  }

  void prev() {
    if (selectedPlayerIndex < listAudio.value.length &&
        selectedPlayerIndex != 0) {
      selectedPlayerIndex -= 1;
    } else {
      selectedPlayerIndex = 0;
    }

    listAudio.refresh();
  }

  void next() {
    if (selectedPlayerIndex < listAudio.value.length - 1) {
      selectedPlayerIndex += 1;
    } else {
      selectedPlayerIndex = listAudio.value.length - 1;
    }

    listAudio.refresh();
  }
}
