import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Obx(
        () => AvatarGlow(
          animate: controller.isListening.value,
          endRadius: 75,
          glowColor: Theme.of(context).primaryColor,
          duration: Duration(milliseconds: 2000),
          repeatPauseDuration: Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton(
            onPressed: () {
              controller.startListening();
            },
            child: Icon(controller.isListening.value ? Icons.stop : Icons.mic),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Hasil Suara ke Text:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 10),
              Obx(
                () => Container(
                  width: double.infinity,
                  height: 100,
                  child: Text(
                    controller.words.value ??
                        'Tekan tombol mic untuk memulai murottal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: controller.words.value != null
                          ? Colors.black87
                          : Colors.black26,
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 200,
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade300,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'https://assets.pikiran-rakyat.com/crop/0x0:0x0/x/photo/2021/11/05/2913233209.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        controller.selectedSurah.value != null
                            ? '${controller.selectedSurah.value?.id}. ${controller.selectedSurah.value?.transliteration}: ${controller.selectedSurah.value?.totalVerses} Ayat'
                            : '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        controller.selectedSurah.value?.translation ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Obx(
                  () => ProgressBar(
                    progress:
                        controller.progressDuration.value ?? Duration.zero,
                    total: controller.maxDuration.value ?? Duration.zero,
                    thumbCanPaintOutsideBar: false,
                    thumbRadius: 0,
                    thumbGlowColor: Colors.transparent,
                    timeLabelPadding: 5,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    onPressed: () => controller.prev(),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => controller.play(),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Obx(
                        () => Icon(
                          !controller.isPlaying.value
                              ? Icons.play_arrow
                              : Icons.pause,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => controller.next(),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
