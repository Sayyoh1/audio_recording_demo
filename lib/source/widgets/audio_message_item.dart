import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../screens/audio_message_screen.dart';
import '../constants/app_colors.dart';
import '../others/amplitude_painter.dart';

class AudioMessageItem extends StatefulWidget {
  final AudioMessage audioMessage;
  final Function() onClick;

  AudioMessageItem({
    Key? key,
    required this.audioMessage,
    required this.onClick,
  }) : super(key: key);

  @override
  _AudioMessageItemState createState() => _AudioMessageItemState();
}

class _AudioMessageItemState extends State<AudioMessageItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _timer;
  String _audioTimer = "00:00";
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(microseconds: widget.audioMessage.duration!),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _formatInitialTimer();
  }

  void _formatInitialTimer() {
    int minutes = widget.audioMessage.timer! ~/ 60;
    int seconds = widget.audioMessage.timer! % 60;
    _audioTimer = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _startTimer() {
    _resetTimer();
    setState(() {
      _audioTimer = "00:00";
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds = timer.tick;
        _audioTimer = _formatDuration(_elapsedSeconds);
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _resumeTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds += 1;
        _audioTimer = _formatDuration(_elapsedSeconds);
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _elapsedSeconds = 0;
      _formatInitialTimer();
    });
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(AudioMessageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    switch (widget.audioMessage.audioState) {
      case AudioState.start:
        _animationController.forward();
        _startTimer();
        break;
      case AudioState.pause:
        _animationController.stop(canceled: false);
        _pauseTimer();
        break;
      case AudioState.resume:
        _animationController.forward();
        _resumeTimer();
        break;
      case AudioState.stop:
        _animationController.reset();
        _resetTimer();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 5),
      alignment: Alignment.centerRight,
      child: Stack(
        children: [
          SvgPicture.asset('assets/svg/audio_message.svg'),
          Container(
            alignment: Alignment.topLeft,
            width: 240,
            height: 100,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: GestureDetector(
                          onTap: widget.onClick,
                          child: Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(23),
                              color: Colors.white,
                            ),
                            child: Icon(
                              widget.audioMessage.audioState == AudioState.start ||
                                  widget.audioMessage.audioState == AudioState.resume
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.audioMassageContainer,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomPaint(
                              painter: AmplitudePainter(widget.audioMessage.waveform!, _animation.value),
                              child: Container(
                                width: 148,
                                height: 28,
                              ),
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  "${widget.audioMessage.audioSize!} - $_audioTimer",
                                  style: TextStyle(fontSize: 12.0, color: Colors.white),
                                ),
                                SizedBox(width: 3),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 2),
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                            child: Text(
                              widget.audioMessage.recordedTime!,
                              style: TextStyle(fontSize: 12.0, color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 2),
                          SvgPicture.asset(
                            widget.audioMessage.beforeListened
                                ? 'assets/svg/double_check.svg'
                                : 'assets/svg/check.svg',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                          SizedBox(width: 3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
