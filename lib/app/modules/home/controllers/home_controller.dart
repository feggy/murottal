import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:murottal/app/data/models/playing_model.dart';
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

  var listAudio = Rx<List<PlayingModel>>([]);
  PlayingModel? audioPlaying;

  var selectedPlayerIndex = 0;

  var repeat = 0;

  var endAt = '';

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
      print('> $p0');
      if (repeat > 0) {
        if (p0.isNotEmpty) {
          isPlaying.value = true;
          audioPlaying = p0[selectedPlayerIndex];
          await player.play(UrlSource(p0[selectedPlayerIndex].url));
        }
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

      if (audioPlaying?.verse == int.parse(endAt)) {
        selectedPlayerIndex = 0;
        repeat -= 1;
      }

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
          isListening.value = speechToText.isListening;
          words.value = result.recognizedWords;

          if (words.value != null && speechToText.isNotListening) {
            final surah = listSurah.firstWhereOrNull((e) =>
                words
                    .toLowerCase()
                    ?.contains(e.transliteration!.toLowerCase()) ??
                false);
            var tmpRepeat = 1;

            if (surah != null) {
              selectedSurah.value = surah;

              final numSurah = surah.id.toString().padLeft(3, '0');
              var startAt = '001';
              endAt = surah.totalVerses.toString().padLeft(3, '0');

              try {
                final sStartAt = words.value!.split('ayat ');
                startAt = sStartAt[1].split(' ')[0].padLeft(3, '0');
                endAt = startAt;
              } catch (e) {}

              try {
                final sEndAt = words.value!.split('sampai ');
                endAt = sEndAt[1].split(' ')[0].padLeft(3, '0');
              } catch (e) {}

              try {
                final sRepeat = words.value!.split('ulang ');
                final rRepeat = sRepeat[1].split(' ')[0];
                tmpRepeat = int.parse(rRepeat);
                print('> $tmpRepeat');
              } catch (e) {}

              listAudio.value.clear();

              final intStartAt = int.parse(startAt);
              final intEndAt = int.parse(endAt);

              if (intStartAt > surah.totalVerses! ||
                  intEndAt > surah.totalVerses!) {
                showToast(
                  'Maaf perintah belum dapat di mengerti oleh sistem',
                  context: Get.overlayContext,
                  animation: StyledToastAnimation.fade,
                  reverseAnimation: StyledToastAnimation.fade,
                );
                return;
              }

              if (intStartAt <= intEndAt) {
                for (var i = intStartAt; i <= intEndAt; i++) {
                  final verse = i.toString().padLeft(3, '0');
                  final url =
                      'https://everyayah.com/data/Alafasy_128kbps/$numSurah$verse.mp3';
                  listAudio.value.add(PlayingModel(
                    url: url,
                    verse: int.parse(verse),
                  ));
                }

                repeat = tmpRepeat;

                selectedPlayerIndex = 0;
                listAudio.refresh();
              } else {
                showToast(
                  'Maaf perintah belum dapat di mengerti oleh sistem',
                  context: Get.overlayContext,
                  animation: StyledToastAnimation.fade,
                  reverseAnimation: StyledToastAnimation.fade,
                );
              }
            } else {
              if (speechToText.isNotListening) {
                errorToast();
              }
            }
          }
        },
      );
    }
  }

  void errorToast() {
    showToast(
      'Maaf perintah belum dapat di mengerti oleh sistem',
      context: Get.overlayContext,
      animation: StyledToastAnimation.fade,
      reverseAnimation: StyledToastAnimation.fade,
    );
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
