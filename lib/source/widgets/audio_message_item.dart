import 'package:audio_recording/source/constants/app_colors.dart';
import 'package:audio_recording/source/constants/sizes.dart';
import 'package:audio_recording/source/others/audio_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AudioMessageItem extends StatelessWidget {
  Function() onClick;
  List<double>? _waveForm;
  bool? _isPlaying;

  AudioMessageItem(
      {super.key,
      required List<double> waveform,
      required bool? isPlaying,
      required this.onClick}) {
    _waveForm = waveform;
    _isPlaying = isPlaying;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(right: 5),
        alignment: Alignment.centerRight,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
                alignment: Alignment.topLeft,
                width: 240,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.audioMassageContainer,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      topRight: Radius.circular(30)),
                ),
                child: Padding(
                    padding: EdgeInsets.only(left: 12, right: 12, top: 12),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: onClick,
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(23),
                                      color: Colors.white),
                                  child: Icon(
                                    _isPlaying == true
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: AppColors.audioMassageContainer,
                                    size: 30,
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.only(left: 10, top: 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomPaint(
                                      painter: AudioVisualizer(_waveForm!),
                                      child: Container(
                                        width: 150,
                                        height: 26,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Row(
                                      children: [
                                        DefaultTextStyle(
                                            style: TextStyle(
                                                fontSize: AppSizes.fonSize,
                                                color: Colors.white),
                                            child: Text("1.5 MB - 00:37")),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 2),
                                          child: Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ))
                          ],
                        ),
                        Expanded(
                            child: Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 7),
                                child: DefaultTextStyle(
                                    style: TextStyle(
                                        fontSize: AppSizes.fonSize,
                                        color: Colors.white),
                                    child: Text("19:37")),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              SvgPicture.asset(
                                'assets/svg/double_check.svg',
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                              ),
                              SizedBox(
                                width: 3,
                              )
                            ],
                          ),
                        ))
                      ],
                    ))),
            Container(
                width: 10,
                height: 98,
                decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                    )))
          ],
        ));
  }
}
